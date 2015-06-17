require 'forwardable'
CertificateResult = Struct.new(:identity, :result) do
  extend Forwardable
  def_delegators :identity, :entity_id, :key_name
  def_delegators :result, :revoked?, :status

  def message
    "The certificate named #{key_name} for the entity '#{entity_id}' has an OCSP status of #{result}"
  end
end
