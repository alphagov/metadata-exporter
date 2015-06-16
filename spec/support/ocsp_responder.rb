require 'r509'
require 'r509/ocsp/responder/server'
require 'dependo'
require 'pki_validity_checker'
require 'net/http'
module OCSPResponder
  SERVER = R509::OCSP::Responder::Server
  def self.start!(pki, port = 4568)
    Dependo::Registry[:validity_checker] = PKIValidityChecker.new(pki)
    SERVER.port = port 
    load_config(pki)
    Thread.new { SERVER.start! }
    wait_until_responder_available!
  end

  def self.wait_until_responder_available!
    available = false
    until available
      begin
      available = (Net::HTTP.get(URI("http://localhost:#{SERVER.port}/status/?")) == "OK")
      rescue Errno::ECONNREFUSED
      end
      sleep 0.01
    end
  end

  def self.load_config(pki)
    ca_config_hash = {
      :ca_cert => 
        R509::Cert.new(:cert => pki.root_ca, :key => R509::PrivateKey.new(:key => pki.root_key)),
      :ocsp_chain => [pki.root_ca]
    }

    ca_config = R509::Config::CAConfig.new(ca_config_hash)
    Dependo::Registry[:config_pool] = R509::Config::CAConfigPool.new({
      "test_pki" => ca_config
    })

    Dependo::Registry[:copy_nonce] = true

    Dependo::Registry[:cache_headers] = true

    Dependo::Registry[:max_cache_age] = 60

    Dependo::Registry[:log] = Logger.new(STDOUT)

    reload_signer!
  end

  def self.reload_signer!
    Dependo::Registry[:ocsp_signer] = R509::OCSP::Signer.new(
      :configs => Dependo::Registry[:config_pool],
      :validity_checker => Dependo::Registry[:validity_checker],
      :copy_nonce => Dependo::Registry[:copy_nonce]
    )
  end

  def self.disable_nonce!
    Dependo::Registry[:copy_nonce] = false
    reload_signer!
  end

  def self.enable_nonce!
    Dependo::Registry[:copy_nonce] = true
    reload_signer!
  end

  def self.stop!
    SERVER.stop!
  end
end
