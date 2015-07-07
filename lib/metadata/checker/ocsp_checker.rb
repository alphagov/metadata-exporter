require 'metadata/saml/parser'
require 'metadata/saml/client'
require 'metadata/ocsp/pem_checker'
require 'metadata/ocsp/certificate_result'
module Metadata
  module Checker
    class OcspChecker
      def initialize
        @metadata_client = Metadata::SAML::Client.new
        @parser = Metadata::SAML::Parser.new
        @pem_checker = Metadata::Ocsp::PemChecker.new
      end

      def check_ocsp(host, ca_files, signing_ca_files, disable_hostname_verification)
        document = @metadata_client.get(host, disable_hostname_verification)
        ocsp_check_entity_certs(document, ca_files) + ocsp_check_signing_certificate(document, signing_ca_files)
      end

      private
      def ocsp_check_entity_certs(document, ca_files)
        certificate_identities = @parser.certificate_identities(document)
        check_certificates(certificate_identities, ca_files)
      end


      def ocsp_check_signing_certificate(document, ca_files)
        return [] if ca_files.empty?
        certificate_identities = @parser.signing_certificate(document)
        check_certificates(certificate_identities, ca_files)
      end

      def check_certificates(certificate_identities, ca_files)
        pems = certificate_identities.keys
        ocsp_results = @pem_checker.check_pems(pems, ca_files)
        select_revoked_certificates(certificate_identities, ocsp_results)
      end

      def select_revoked_certificates(certificate_identities, ocsp_results)
        certificate_identities.map do |pem, identities|
          identities.map do |identity|
            CertificateResult.new(identity, ocsp_results[pem])
          end
        end.flatten.select(&:revoked?)
      end
      
    end
  end
end
