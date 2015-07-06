require 'metadata/saml/parser'
require 'metadata/saml/client'
require 'metadata/certificate_repository'
require 'metadata/ocsp/checker'
require 'metadata/ocsp/certificate_result'
module Metadata
  module Checker
    def self.check_ocsp(host, ca_files, signing_ca_files, disable_hostname_verification)
      metadata_client = Metadata::SAML::Client.new
      document = metadata_client.get(host, disable_hostname_verification)
      ocsp_check_entity_certs(document, ca_files) + ocsp_check_signing_certificate(document, signing_ca_files)
    end

    def self.ocsp_check_entity_certs(document, ca_files)
      parser = Metadata::SAML::Parser.new
      certificate_identities = parser.certificate_identities(document)
      pems = certificate_identities.keys
      ocsp_results = ocsp_check_pems(pems, ca_files)
      results = certificate_identities.map do |pem, identities|
        identities.map do |identity|
          CertificateResult.new(identity, ocsp_results[pem])
        end
      end.flatten
      results.select(&:revoked?)
    end

    def self.ocsp_check_signing_certificate(document, ca_files)
      return [] if ca_files.empty?
      parser = Metadata::SAML::Parser.new
      certificate_identities = parser.signing_certificate(document)
      pems = certificate_identities.keys
      ocsp_results = ocsp_check_pems(pems, ca_files)
      results = certificate_identities.map do |pem, identities|
        identities.map do |identity|
          CertificateResult.new(identity, ocsp_results[pem])
        end
      end.flatten
      results.select(&:revoked?)
    end

    def self.ocsp_check_pems(pems, ca_files)
      ca_certs = ca_files.map { |file| OpenSSL::X509::Certificate.new(File.read(file)) }
      issuer_repository = CertificateRepository.new(ca_certs)
      ocsp_checker = Metadata::Ocsp::Checker.new
      pems.each.with_object({}) do |pem, results|
        results[pem] = make_ocsp_check(ocsp_checker, pem, issuer_repository)
      end
    end

    def self.make_ocsp_check(ocsp_checker, pem, issuer_repository)
      cert = make_certificate(pem)
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

