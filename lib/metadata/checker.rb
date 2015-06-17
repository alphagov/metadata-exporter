require 'metadata/saml/parser'
require 'metadata/saml/client'
require 'metadata/certificate_repository'
require 'metadata/ocsp/checker'
require 'metadata/ocsp/certificate_result'
module Metadata
  module Checker
    def self.check_ocsp(host, ca_files)
      parser = Metadata::SAML::Parser.new
      metadata_client = Metadata::SAML::Client.new
      ca_certs = ca_files.map { |file| OpenSSL::X509::Certificate.new(File.read(file)) }
      issuer_repository = CertificateRepository.new(ca_certs)
      document = metadata_client.get(host)
      certificate_identities = parser.certificate_identities(document)
      certificates = certificate_identities.keys
      ocsp_checker = Metadata::Ocsp::Checker.new
      ocsp_results = certificates.each.with_object({}) do |cert, results|
        results[cert] = make_ocsp_check(ocsp_checker, cert, issuer_repository)[cert]
      end
      results = certificate_identities.map do |cert, identities|
        identities.map do |identity|
          CertificateResult.new(identity, ocsp_results[cert])
        end
      end.flatten
      results.select(&:revoked?)
    end

    def self.make_ocsp_check(ocsp_checker, cert, issuer_repository)
      chain = issuer_repository.find_chain(cert)
      store = chain.store
      issuer = chain.first
      ocsp_checker.check([cert], issuer, store)
    end
  end
end

