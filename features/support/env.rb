$: << File.expand_path("../../spec/support", File.dirname(__FILE__))
require 'aruba/cucumber'

require 'pki'
PKIS = {}

require 'base64'

require 'metadata_helper'
require 'metadata_server'
require 'ocsp_responder'
World(MetadataHelper)

Before do
  if @metadata_server
    @metadata_server.shutdown
  end
end

After do
  if @metadata_server
    @metadata_server.shutdown
  end
end
