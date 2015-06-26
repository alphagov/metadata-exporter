require 'open-uri'
require 'openssl'
module Metadata
  module SAML
    class Client
      def get(endpoint, disable_hostname_verification)
        if disable_hostname_verification
          Nokogiri::XML(open(endpoint, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}))
        else
          Nokogiri::XML(open(endpoint))
        end
      end
    end
  end
end
