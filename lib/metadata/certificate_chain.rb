require 'openssl'
module Metadata
  class CertificateChain
    include Enumerable
    include Comparable

    attr_reader :chain

    def <=>(other)
      if other.is_a? CertificateChain
        self.chain <=> other.chain
      else
        nil
      end
    end

    def initialize(*certificates)
      @chain = certificates
    end

    def each
      @chain.each do |certificate|
        yield certificate
      end
    end

    def store
      store = OpenSSL::X509::Store.new
      @chain.each {|cert| 
        store.add_cert cert
      }
      store
    end
  end
end
