require 'metadata/saml/entity'
require 'openssl'
require 'nokogiri'
require 'base64'

module Metadata
  module SAML
    class Parser
      def certificate_identities(document)
        certificate_identities = Hash.new {|hash, key| hash[key] = [] }
        entity_descriptors = document.xpath(".//md:EntityDescriptor")
        entity_descriptors.each { |entity|
          entity_id = entity["entityID"]
          keys = entity.xpath(".//md:KeyDescriptor")
          keys.each { |key|
            key_name = key.xpath("./ds:KeyInfo/ds:KeyName", "ds" => "http://www.w3.org/2000/09/xmldsig#").first.content
            pem = key.xpath("./ds:KeyInfo/ds:X509Data/ds:X509Certificate", "ds" => "http://www.w3.org/2000/09/xmldsig#").first.content
            der = Base64.decode64(pem)
            certificate = OpenSSL::X509::Certificate.new(der)
            certificate_identities[certificate] << Entity.new(entity_id, key_name)
          }
        }
        certificate_identities.freeze
      end
    end
  end
end
