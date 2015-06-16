require "r509"

class PKIValidityChecker < R509::Validity::Checker
  attr_reader :pki
  def initialize(pki)
    @pki = pki
  end

  def check(issuer,serial)
    raise ArgumentError.new("Serial and issuer must be provided") if serial.to_s.empty? or issuer.to_s.empty?
    raise "wrong issuer" if pki.root_ca.subject.to_s != issuer
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
