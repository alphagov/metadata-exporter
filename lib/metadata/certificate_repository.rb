require 'metadata/certificate_chain'

module Metadata
  class CertificateRepository
    def initialize(certificates)
      @issuer_certificates = certificates.inject({}) do |hash, cert|
        hash[cert.subject] = cert
        hash
      end
    end
    def find_chain(certificate)
      issuers = []
      begin
        issuer = @issuer_certificates[certificate.issuer]
        issuers << issuer unless issuer.nil?
        certificate = issuer
      end until issuer.nil? || (issuer.subject == issuer.issuer)
      CertificateChain.new(*issuers)
    end
  end
end
