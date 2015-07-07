module Metadata
  module Certificate
    class CertificateFactory
      def from_inline_pem(pem)
        der = Base64.decode64(pem)
        OpenSSL::X509::Certificate.new(der)
      end

    end
  end
end
