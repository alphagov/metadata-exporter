Given(/^there is metadata at http:\/\/localhost:(\d+)$/) do |port|
  MetadataServer.new(port, @metadata).start!
end

Given(/^there is an OCSP responder for (\w+)$/) do |pki_name|
  pki = PKIS.fetch(pki_name)
  port = pki.ocsp_host.port
  OCSPResponder.start!(pki, port)
end

Given(/^there are the following PKIs:$/) do |table|
  table.hashes.each do |pki|
    new_pki = PKI.new(pki["name"], pki["ocsp_host"])
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
    cert_value = Base64.encode64(cert.to_der)
    metadata_entries[ent.fetch("entity_id")] << { :key_name => ent['key_name'], :cert_value => cert_value}
  end
  @metadata = build_metadata(metadata_entries)
end

