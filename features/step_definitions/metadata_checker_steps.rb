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
    cert = pki.sign(pki.generate_cert)
    if ent["status"] == "revoked"
      pki.revoke(cert)
    end
    cert_value = pki.inline_pem(cert)
    metadata_entries[ent.fetch("entity_id")] << { :key_name => ent['key_name'], :cert_value => cert_value}
  end
  @metadata = build_metadata(metadata_entries)
end

