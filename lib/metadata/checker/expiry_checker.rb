require 'metadata/saml/parser'
require 'metadata/saml/client'
require 'metadata/expiry/certificate_result'

module Metadata
  module Checker
    class ExpiryChecker
      def initialize
        @metadata_client = Metadata::SAML::Client.new
        @parser = Metadata::SAML::Parser.new
        @certificate_factory = Certificate::CertificateFactory.new
      end

      def check_expiry(host, disable_hostname_verification, warning_threshold_days, critical_threshold_days)
        document = @metadata_client.get(host, disable_hostname_verification)
        certificate_identities = @parser.certificate_identities(document)
        crit = Array.new
        warnings = Array.new
        warn_threshold = 60*60*24*warning_threshold_days
        crit_threshold = 60*60*24*critical_threshold_days
        certificate_identities.each { | pem, entity |
          expiry = @certificate_factory.from_inline_pem(pem).not_after
          if (expiry < Time.now) 
            crit.push(CertificateExpiryResult.new(entity[0], expiry, "EXPIRED"))
          elsif (expiry < (Time.now+crit_threshold))
            crit.push(CertificateExpiryResult.new(entity[0], expiry, "ALMOST EXPIRED"))
          elsif (expiry < (Time.now+warn_threshold)) 
            warnings.push(CertificateExpiryResult.new(entity[0], expiry, "NEAR EXPIRY"))
          end
        }
        return crit, warnings
      end

    end
  end
end
