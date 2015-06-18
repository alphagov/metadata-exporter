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
      ocsp_checker = Metadata::Ocsp::Checker.new
      ca_certs = ca_files.map { |file| OpenSSL::X509::Certificate.new(File.read(file)) }
      issuer_repository = CertificateRepository.new(ca_certs)

      document = metadata_client.get(host)
      certificate_identities = parser.certificate_identities(document)
      pems = certificate_identities.keys
      ocsp_results = pems.each.with_object({}) do |pem, results|
        cert = make_certificate(pem)
        results[pem] = make_ocsp_check(ocsp_checker, cert, issuer_repository)
      end

      results = certificate_identities.map do |pem, identities|
        identities.map do |identity|
          CertificateResult.new(identity, ocsp_results[pem])
        end
      end.flatten
      results.select(&:revoked?)
    end

    def self.make_ocsp_check(ocsp_checker, cert, issuer_repository)
      chain = issuer_repository.find_chain(cert)
      store = chain.store
      issuer = chain.first
      ocsp_checker.check([cert], issuer, store)[cert]
    end

    def self.make_certificate(pem)
      der = Base64.decode64(pem)
      OpenSSL::X509::Certificate.new(der)
    end
  end
end

