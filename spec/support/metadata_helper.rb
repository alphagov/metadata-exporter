require 'erb'
module MetadataHelper
  TEMPLATE = <<XML
<?xml version="1.0" encoding="UTF-8"?>
<md:EntitiesDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ID="_entities" validUntil="2015-06-19T14:21:40+01:00">
  <% entries.each do |entity_id, signature_details| -%>
  <md:EntityDescriptor ID="SOME ID" entityID="<%= entity_id %>" xsi:type="md:EntityDescriptorType" validUntil="2015-06-19T14:21:40+01:00">
  <md:SPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol" xsi:type="md:SPSSODescriptorType">
  <% signature_details.each do |details| -%>
    <md:KeyDescriptor use="encryption" xsi:type="md:KeyDescriptorType">
      <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xsi:type="ds:KeyInfoType">
        <ds:KeyName xmlns:xs="http://www.w3.org/2001/XMLSchema"><%= details[:key_name] %></ds:KeyName>
        <ds:X509Data xsi:type="ds:X509DataType">
          <ds:X509Certificate><%= details[:cert_value] %></ds:X509Certificate>
        </ds:X509Data>
      </ds:KeyInfo>
    </md:KeyDescriptor>
    <% end %>
  </md:SPSSODescriptor>
</md:EntityDescriptor>
<% end %>
</md:EntitiesDescriptor>
XML

  def build_metadata(entries)
    ERB.new(TEMPLATE, nil, '<->').result binding
  end
end
