require 'metadata/saml/entity'
require 'openssl'
require 'nokogiri'
require 'base64'
require 'time'

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
            key_use = key.xpath("./@use", "md" => "urn:oasis:names:tc:SAML:2.0:metadata").first.value
            certificate_identities[pem] << Entity.new(entity_id, key_name, key_use)
          }
        }
        certificate_identities
      end

      def signing_certificate(document)
        pem = document.xpath(".//ds:Signature/ds:KeyInfo/ds:X509Data/ds:X509Certificate", "ds" => "http://www.w3.org/2000/09/xmldsig#").first.content
        { pem => [ Entity.new("metadata_signing_certificate") ] }
      end

    def valid_until(document)
      # grafana prefers timestamps to be in milliseconds :(
      attributes = document.xpath("./md:EntitiesDescriptor/@validUntil", "md" => "urn:oasis:names:tc:SAML:2.0:metadata")
      attribute = attributes.first
      Time.parse(attribute.value).to_f*1000
    end
    end
  end
end
