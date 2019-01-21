require 'net/http'

Given(/^there is metadata at http:\/\/localhost:(\d+)$/) do |port|
  raise "@metadata must be set!" if @metadata.nil?
  MetadataServer.new(port, @metadata).start!
end

Given(/^the OCSP port is (\d+)$/) do |port|
  @ocsp_port = port
end

Given(/^there is an OCSP responder$/) do
  raise "@ocsp_port must be set!" if @ocsp_port.nil?
  OCSPResponder.start!(PKIS.values, @ocsp_port)
end

Given(/^there are the following PKIs:$/) do |table|
  raise "@ocsp_port must be set!" if @ocsp_port.nil?
  ocsp_host = "http://localhost:#@ocsp_port"
  table.hashes.each do |pki|
    new_pki = PKI.new(pki["name"], ocsp_host)
    PKIS[pki["name"]] = new_pki
    write_file(pki["cert_filename"], new_pki.root_ca)
  end
end

Given(/^the following certificates are defined in metadata:$/) do |table|
  metadata_entries = Hash.new do |hash, key|
    hash[key] = []
  end
  table.hashes.each do |ent|
    pki = PKIS.fetch(ent["pki"])
    if ent["status"] == "expired"
      cert = pki.generate_cert_with_expiry(Time.now-(60*60*24*15), "EXPIRED CERT")
    elsif ent["status"] == "almost_expired"
      cert = pki.generate_cert_with_expiry(Time.now+(60*60*24*2), "ALMOST EXPIRED CERT")
    elsif ent["status"] == "near_expiry"
      cert = pki.generate_cert_with_expiry(Time.now+(60*60*24*20), "NEARLY EXPIRED CERT")
    else
      cert = pki.generate_cert
    end
    signed_cert = pki.sign(cert)
    if ent["status"] == "revoked"
      pki.revoke(signed_cert)
    end
    cert_value = pki.inline_pem(signed_cert)
    metadata_entries[ent.fetch("entity_id")] << { :key_name => ent['key_name'], :cert_value => cert_value}
  end
  @metadata = build_metadata(metadata_entries)
end

Given(/^the metadata is signed by a (revoked )?certificate belonging to (\w+)$/) do |revoked, pki_name|
  pki = PKIS.fetch(pki_name)
  signing_public_certificate, signing_private_key = *pki.generate_signed_cert_and_private_key
  @metadata = sign_metadata(@metadata, signing_private_key, signing_public_certificate)
  if revoked
    pki.revoke(signing_public_certificate)
  end
end

Then(/^the metrics should contain exactly:$/) do |string|
    uri = URI('http://localhost:9199/metrics')
    for i in 0..10
        begin
            Net::HTTP.start(uri.host, uri.port) do |http|
                response = http.request Net::HTTP::Get.new uri
                return response.body if response.code eq 200
            end
        rescue
        end
        sleep 1
    end
end
