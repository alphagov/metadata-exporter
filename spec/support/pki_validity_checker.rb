require "r509"

class PKIValidityChecker < R509::Validity::Checker
  attr_reader :pkis
  def initialize(pkis)
    @pkis = pkis.each.with_object({}) do |pki, pki_hash|
      subject = pki.root_ca.subject.to_s
      pki_hash[subject] = pki
    end
  end

  def check(issuer,serial)
    raise ArgumentError.new("Serial and issuer must be provided") if serial.to_s.empty? or issuer.to_s.empty?
    pki = @pkis.fetch(issuer)
    revocation_data = pki.revocation_data(serial)
    if revocation_data
      R509::Validity::Status.new(
        :status => R509::Validity::REVOKED,
        :revocation_time => revocation_data[:time].to_i,
        :revocation_reason => revocation_data[:reason]
      )
    else
      R509::Validity::Status.new(:status => R509::Validity::VALID)
    end
  end

  def is_available?
    true
  end

end
