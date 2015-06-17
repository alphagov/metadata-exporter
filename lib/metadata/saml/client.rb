require 'open-uri'
module Metadata
  module SAML
    class Client
      def get(endpoint)
        Nokogiri::XML(open(endpoint))
      end
    end
  end
end
