require 'open-uri'
require 'openssl'
module Metadata
  module SAML
    class Client
      def get(endpoint, disable_hostname_verification)
        uri = URI.parse(endpoint)
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https'
          http.use_ssl = true
          if disable_hostname_verification
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
        end
        if uri.path.nil? || uri.path.empty?
            path = '/'
        else
            path = uri.path
        end
        resp = http.get(path)
        Nokogiri::XML(resp.body)
      end
    end
  end
end
