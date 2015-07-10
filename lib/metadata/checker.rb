require 'metadata/checker/ocsp_checker'
require 'metadata/checker/expiry_checker'

module Metadata
  module Checker
    def self.check_ocsp(host, ca_files, signing_ca_files, disable_hostname_verification)
      OcspChecker.new.check_ocsp(host, ca_files, signing_ca_files, disable_hostname_verification)
    end
    def self.check_expiry(host, disable_hostname_verification, warning_threshold_days, critical_threshold_days)
      ExpiryChecker.new.check_expiry(host, disable_hostname_verification, warning_threshold_days, critical_threshold_days)
    end
  end
end

