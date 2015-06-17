require 'spec_helper'
require 'metadata/certificate_repository'
require 'pki'
require 'pp'
module Metadata
  describe CertificateRepository do
    context "#find_chain" do
      context "for a given certificate" do
        it "will try to find the certificate chain" do
          root_certificate = double(:root, :issuer => "MY ROOT", :subject => "MY ROOT")
          intermediary_certificate = double(:inter, :issuer => "MY ROOT", :subject => "MY INTERMEDIARY")
          other_intermediary_certificate = double(:other_inter, :issuer => "MY ROOT", :subject => "MY OTHER INTERMEDIARY")
          my_certificate = double(:root, :issuer => "MY INTERMEDIARY", :subject => "MY CERTIFICATE")
          certificates = [root_certificate, other_intermediary_certificate, intermediary_certificate]
          chain = CertificateRepository.new(certificates).find_chain(my_certificate)
          expect(chain).to eq CertificateChain.new(intermediary_certificate, root_certificate)
        end

        it "will return an empty chain if the certificate can't find its issuers" do
          root_certificate = double(:root, :issuer => "MY ROOT", :subject => "MY ROOT")
          intermediary_certificate = double(:inter, :issuer => "MY ROOT", :subject => "MY INTERMEDIARY")
          my_certificate = double(:root, :issuer => "OTHER INTERMEDIARY", :subject => "MY CERTIFICATE")
          certificates = [root_certificate, intermediary_certificate]
          chain = CertificateRepository.new(certificates).find_chain(my_certificate)
          expect(chain).to eq CertificateChain.new()
        end
      end
    end
  end
end
