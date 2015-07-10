require 'forwardable'
CertificateExpiryResult = Struct.new(:identity, :expiry, :result) do
  extend Forwardable
  def_delegators :identity, :entity_id, :key_name

  def message
    "The certificate named #{key_name} for the entity '#{entity_id}' has a status of #{result} (with expiry at #{expiry})"
  end
end
