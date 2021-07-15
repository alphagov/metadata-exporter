require 'base64'
require 'ostruct'
require 'metadata/sources/client'


describe "Client" do
  let(:octokit_double) { instance_double(Octokit::Client) }
  subject(:client) { Metadata::Sources::Client.new("my_access_token", "prod") }

  describe "#get" do
    it "should return all hub and idp certs in a list" do
      expect(Octokit::Client)
              .to receive(:new)
              .with(access_token: "my_access_token")
              .and_return(octokit_double)

      allow(octokit_double)
              .to receive(:contents)
              .with(Metadata::Sources::METADATA_REPO, path: "sources/prod/hub.yml")
              .and_return(OpenStruct.new(content: File.open('fixtures/sources/test/hub.yml').read))

      allow(octokit_double)
              .to receive(:contents)
              .with(Metadata::Sources::METADATA_REPO, path: "sources/prod/idps")
              .and_return([{path: 'idp0.yml'}, {path: 'idp1.yml'}, {path: 'idp2.yml'}])

      3.times do |i|
        allow(octokit_double)
                .to receive(:contents)
                .with(Metadata::Sources::METADATA_REPO, path: "idp#{i}.yml")
                .and_return(OpenStruct.new(content: File.open("fixtures/sources/test/idps/idp#{i}.txt").read))
      end


      expect(client.get).to eq(build_expected_certs)
    end
  end

  def build_expected_certs
    expected_certs = []
    base64_yaml_to_hash("fixtures/sources/test/hub.yml")["signing_certificates"].map { |cert| expected_certs << cert['x509'].gsub("\n", '') }
    expected_certs << base64_yaml_to_hash("fixtures/sources/test/hub.yml")["encryption_certificate"]["x509"].gsub("\n", '')
    3.times { |i| base64_yaml_to_hash("fixtures/sources/test/idps/idp#{i}.txt")["signing_certificates"].map { |cert| expected_certs << cert['x509'].gsub("\n", '')} }
    expected_certs
  end

  def base64_yaml_to_hash(file)
    YAML.load(Base64.decode64(File.open(file).read))
  end
end