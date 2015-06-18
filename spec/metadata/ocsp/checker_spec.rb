require 'spec_helper'

require 'pki'
require 'ocsp_responder'
require 'metadata/ocsp/checker'
describe Metadata::Ocsp::Checker do
  before(:all) do
    @pki = PKI.new
    OCSPResponder.start!([@pki], 4568)
  end

  before(:each) do
    OCSPResponder.enable_nonce!
  end

  let(:pki) { @pki }
  let(:checker) {
    Metadata::Ocsp::Checker.new
  }

  let(:good_store) {
    store = OpenSSL::X509::Store.new
    store.add_cert pki.root_ca
  }

  it "will let us know if a certificate is good" do
    signed = pki.sign(pki.generate_cert)
    result = checker.check([signed], pki.root_ca, good_store)
    expect(result).to eql({signed => Metadata::Ocsp::Result.new(:good)})
  end

  it "will let us know if a certificate is revoked" do
    unsigned = pki.generate_cert
    signed = pki.sign(unsigned)
    pki.revoke(signed)
    result = checker.check([signed], pki.root_ca, good_store)
    expect(result).to eql({signed => Metadata::Ocsp::Result.new(:revoked, :unspecified)})
  end

  it "will error when the cert doesn't belong to the OCSP pki" do
    other_pki = PKI.new 
    unsigned = other_pki.generate_cert
    signed = other_pki.sign(unsigned)
    store = OpenSSL::X509::Store.new
    store.add_cert other_pki.root_ca
    expect{
      checker.check([signed], other_pki.root_ca, good_store) 
    }.to raise_error Metadata::Ocsp::CheckerError, "response was not a success"
  end

  it "will error when the store doesn't recognise the cert from the ocsp response" do
    other_pki = PKI.new 
    signed = pki.sign(pki.generate_cert)
    store = OpenSSL::X509::Store.new
    store.add_cert other_pki.root_ca
    expect{
      checker.check([signed], pki.root_ca, store) 
    }.to raise_error Metadata::Ocsp::CheckerError, "could not verify response against issuer certificates"
  end

  it "will error when the nonces doen't match't recognise the cert from the ocsp response" do
    signed = pki.sign(pki.generate_cert)
    OCSPResponder.disable_nonce!
    expect{
      checker.check([signed], pki.root_ca, good_store) 
    }.to raise_error Metadata::Ocsp::CheckerError, "nonces do not match"
  end

end
