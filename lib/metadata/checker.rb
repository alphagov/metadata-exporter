require 'metadata/checker/ocsp_checker'

module Metadata
  module Checker
    def self.check_ocsp(host, ca_files, signing_ca_files, disable_hostname_verification)
      OcspChecker.new.check_ocsp(host, ca_files, signing_ca_files, disable_hostname_verification)
    end
  end
end

