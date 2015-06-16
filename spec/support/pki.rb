require 'openssl'
class PKI
  attr_reader :root_ca, :root_key
  def initialize(cn = "TEST CA", ocsp_host = "http://localhost:4568")
    @root_ca = generate_root_certificate(cn)
    @revoked_certificates = {}
    @ocsp_host = ocsp_host
  end

  def generate_root_certificate(cn)
    @root_key = OpenSSL::PKey::RSA.new 2048 # the CA's public/private key
    root_ca = OpenSSL::X509::Certificate.new
    root_ca.version = 2 # cf. RFC 5280 - to make it a "v3" certificate
    root_ca.serial = 1
    root_ca.subject = OpenSSL::X509::Name.parse "/DC=org/DC=TEST/CN=#{cn}"
    root_ca.issuer = root_ca.subject # root CA's are "self-signed"
    root_ca.public_key = @root_key.public_key
    root_ca.not_before = Time.now
    root_ca.not_after = root_ca.not_before + 2 * 365 * 24 * 60 * 60 # 2 years validity
    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = root_ca
    ef.issuer_certificate = root_ca
    root_ca.add_extension(ef.create_extension("basicConstraints","CA:TRUE",true))
    root_ca.add_extension(ef.create_extension("keyUsage","keyCertSign, cRLSign", true))
    root_ca.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
    root_ca.add_extension(ef.create_extension("authorityKeyIdentifier","keyid:always",false))
    root_ca.sign(@root_key, OpenSSL::Digest::SHA256.new)
  end

  attr_reader :root_ca

  def sign(cert)
    cert.not_before = Time.now
    cert.not_after = cert.not_before + 1 * 365 * 24 * 60 * 60 # 1 years validity
    cert.issuer = @root_ca.subject # root CA is the issuer
    ef = OpenSSL::X509::ExtensionFactory.new
    ef.subject_certificate = cert
    ef.issuer_certificate = root_ca
    cert.add_extension(ef.create_extension("keyUsage","digitalSignature", true))
    cert.add_extension(ef.create_extension("subjectKeyIdentifier","hash",false))
    ocsp_extension = ef.create_extension("authorityInfoAccess","OCSP;URI:#{@ocsp_host}")
    cert.add_extension(ocsp_extension)
    cert.sign(@root_key, OpenSSL::Digest::SHA256.new)
    cert
  end

  def revoke(certificate)
    @revoked_certificates[certificate.serial.to_i] = { time: Time.now, reason: 0 }
  end

  def revocation_data(serial)
    @revoked_certificates[serial.to_i]
  end

  def generate_cert(cn = "GENERATED TEST CERTIFICATE")
    key = OpenSSL::PKey::RSA.new 2048
    cert = OpenSSL::X509::Certificate.new
    cert.version = 2
    cert.serial = 2
    cert.subject = OpenSSL::X509::Name.parse "/DC=org/DC=TEST/CN=#{cn}"
    cert.public_key = key.public_key
    cert
  end
end

