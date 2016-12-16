require 'net/http'
require 'metadata/ocsp/checker_error'
require 'metadata/ocsp/update_time_checker'
require 'metadata/ocsp/result'

module Metadata
  module Ocsp
    class Client
      def initialize(options = {})
        @update_time_checker = options.fetch(:update_time_checker){UpdateTimeChecker.new} 
      end

      def check(certificates, issuer, store)
        cert_ids = certificates.inject({}) {|hash, certificate|
          hash[certificate] = OpenSSL::OCSP::CertificateId.new(certificate, issuer)
          hash
        }
        ocsp_uri = find_ocsp_uri(certificates.first)
        ocsp_request = build_ocsp_request_body(cert_ids.values)
        ocsp_response = make_ocsp_request(ocsp_uri, ocsp_request)
        cert_id_statuses = check_response(ocsp_request, ocsp_response, cert_ids.values, store)
        certificates.inject({}) { |hash, certificate|
          hash[certificate] = cert_id_statuses[cert_ids[certificate]]
          hash
        }
      end

      private
      def find_ocsp_uri(certificate)
        authority_info_access = certificate.extensions.find do |extension|
          extension.oid == 'authorityInfoAccess'
        end

        raise "The certificate #{certificate.subject.to_s} does not contain an 'authorityInfoAccess' extension" if authority_info_access.nil?

        descriptions = authority_info_access.value.split "\n"
        ocsp = descriptions.find do |description|
          description.start_with? 'OCSP'
        end

        URI ocsp[/URI:(.*)/, 1]
      end

      def build_ocsp_request_body(cert_ids)
        request = OpenSSL::OCSP::Request.new
        cert_ids.each do |cert_id|
          request.add_certid(cert_id)
        end
        request.add_nonce
        request
      end

      def make_ocsp_request(uri, ocsp_request)
        http = Net::HTTP.new(uri.host, uri.port)
        req = Net::HTTP::Post.new(uri)
        req.content_type = 'application/ocsp-request'
        req.body = ocsp_request.to_der
        http_response = http.request(req)
        if http_response.code != "200"
          raise CheckerError, "Invalid response code #{http_response.code} from OCSP responder"
        end
        OpenSSL::OCSP::Response.new(http_response.body)
      end

      def check_response(ocsp_request, ocsp_response, cert_ids, store)
        fail CheckerError, "response was not a success" unless ocsp_response.status_string == "successful"
        fail CheckerError, "nonces do not match" if ocsp_request.check_nonce(ocsp_response.basic) != 1

        basic_response = ocsp_response.basic
        fail CheckerError, "could not verify response against issuer certificates" unless basic_response.verify([], store)
        statuses = basic_response.status
        results = statuses.inject({}) do |hash,status|
          received_cert_id, revocation_status, revocation_reason, _, this_update, _, _ = *status
          cert_ids.each do |cert_id|
            if received_cert_id.cmp(cert_id)
              @update_time_checker.check_time!(this_update)
              hash[cert_id] = Result.new(
                REVOCATION_STATUS.fetch(revocation_status),
                CRLREASON[revocation_reason]
              )
            end
          end
          hash
        end
        ensure_all_cert_ids_found!(results, cert_ids)
        results
      end

      def ensure_all_cert_ids_found!(hash, cert_ids)
        unless hash.keys.sort == cert_ids.sort
          fail CheckerError, "some certificates were not found in the OCSP response"
        end
      end

      CRLREASON = {
        0 => :unspecified,
        1 => :key_compromise,
        2 => :ca_compromise,
        3 => :affiliation_changed,
        4 => :superseded,
        5 => :cessation_of_operation,
        6 => :certificate_hold,
        8 => :remove_from_crl,
        9 => :privilege_withdrawn,
        10 => :aa_compromise,
      }

      REVOCATION_STATUS = {
        0 => :good,
        1 => :revoked,
        2 => :unknown
      }
    end
  end
end
