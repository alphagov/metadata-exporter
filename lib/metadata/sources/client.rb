# frozen_string_literal: true

require 'base64'
require "faraday-http-cache"
require 'octokit'
require 'yaml'

module Metadata
  module Sources

    METADATA_REPO = "alphagov/verify-metadata"

    class Client

      def initialize(access_token, env)
        @octokit = Octokit::Client.new(access_token: access_token, middleware: build_faraday_http_cache)
        @env = env
      end

      def get
        [hub_certs, idp_certs].flatten
      end

      private

      def hub_certs
        hub_yaml_content = get_yaml_content("sources/#{@env}/hub.yml")
        [extract_signing_certs(hub_yaml_content), extract_encryption_cert(hub_yaml_content)].flatten
      end

      def idp_certs
        [idp_yaml_files.map {| file | extract_signing_certs(get_yaml_content(file))}].flatten
      end

      def idp_yaml_files
        unless @env == "test"
          @octokit.contents(
            METADATA_REPO,
            path: "sources/#{@env}/idps"
          ).map { |file| file[:path] }
        else
          # This is a horrible way of stubbing Octokit for the feature tests. Getting proper stubbing to work is even more horrible.
          return %w[sources/test/idps/idp0.txt sources/test/idps/idp1.txt sources/test/idps/idp2.txt]
        end

      end

      def get_yaml_content(path)
        YAML.load(
          Base64.decode64(
            b64_content(path)
          )
        )
      end

      def b64_content(path)
        unless @env == 'test'
          return @octokit.contents(
            METADATA_REPO,
            path: path
          ).content
        else
          # This is a horrible way of stubbing Octokit for the feature tests. Getting proper stubbing to work is even more horrible.
          File.read(File.dirname(__FILE__) + "/../../../fixtures/#{path}")
        end

      end

      def extract_signing_certs(content)
        content["signing_certificates"].map { |cert| cert['x509'].gsub("\n", '') }
      end

      def extract_encryption_cert(content)
        content["encryption_certificate"]["x509"].gsub("\n", '')
      end

      def build_faraday_http_cache
        Faraday::RackBuilder.new do |builder|
          builder.use Faraday::HttpCache, serializer: Marshal, shared_cache: false
          builder.use Octokit::Response::RaiseError
          builder.adapter Faraday.default_adapter
        end
      end
    end
  end
end