require 'openssl'
require 'metadata/certificate/certificate_factory'
require 'metadata/certificate_repository'
require 'metadata/ocsp/checker'
module Metadata
  module Ocsp
    class PemChecker
      def initialize(certificate_factory: Certificate::CertificateFactory.new, ocsp_checker: Ocsp::Checker.new)
        @certificate_factory = certificate_factory
        @ocsp_checker = ocsp_checker
      end

      def check_pems(pems, ca_files)
        ca_certs = ca_files.map { |file| OpenSSL::X509::Certificate.new(File.read(file)) }
        issuer_repository = CertificateRepository.new(ca_certs)
        pems.each.with_object({}) do |pem, results|
          results[pem] = check_pem(pem, issuer_repository)
        end
      end

      def check_pem(pem, issuer_repository)
        cert = @certificate_factory.from_inline_pem(pem)
        chain = issuer_repository.find_chain(cert)
        store = chain.store
        issuer = chain.first
        @ocsp_checker.check([cert], issuer, store)[cert]
      end
    end
  end
end
