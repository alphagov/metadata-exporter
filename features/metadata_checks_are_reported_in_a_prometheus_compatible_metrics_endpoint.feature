Feature: metadata checks are reported in a prometheus compatible metrics endpoint

  In order to guarantee the health of the federation,
  As a person running a Verify Hub,
  I want to be capture metrics about certificates in the Verify Federation metadata

  Background:
    Given the OCSP port is 54000

  Scenario: Check healthy metadata
    Given there are the following PKIs:
      | name         | cert_filename    |
      | TEST_PKI_ONE | test_pki_one.crt |
    Given the following certificates are defined in metadata:
      | entity_id | key_name  | pki          | status |
      | foo       | foo_key_1 | TEST_PKI_ONE | good   |
      | foo       | foo_key_2 | TEST_PKI_ONE | good   |
      | bar       | bar_key_1 | TEST_PKI_ONE | good   |
    And there is metadata at http://localhost:53110
    And there is an OCSP responder
    When I start the metadata server on port 53110 with ca test_pki_one.crt
    Then the metrics should contain exactly:
    """
      # TYPE verify_federation_certificate_expiry gauge
      # HELP verify_federation_certificate_expiry The NotAfter date of the given X.509 SAML certificate
      verify_federation_certificate_expiry{entity_id="foo",key_use="encryption",key_name="foo_key_1",serial="2"} 1579697902000.0
      verify_federation_certificate_expiry{entity_id="foo",key_use="encryption",key_name="foo_key_2",serial="3"} 1579697902000.0
      verify_federation_certificate_expiry{entity_id="bar",key_use="encryption",key_name="bar_key_1",serial="4"} 1579697903000.0
      # TYPE verify_federation_certificate_ocsp_success gauge
      # HELP verify_federation_certificate_ocsp_success If an OCSP check of the given X.509 SAML certificate is good (1) or bad (0)
      verify_federation_certificate_ocsp_success{entity_id="foo",key_use="encryption",key_name="foo_key_1",serial="2"} 1.0
      verify_federation_certificate_ocsp_success{entity_id="foo",key_use="encryption",key_name="foo_key_2",serial="3"} 1.0
      verify_federation_certificate_ocsp_success{entity_id="bar",key_use="encryption",key_name="bar_key_1",serial="4"} 1.0

    """
#
#  Scenario: Check metadata with certificate close to expiry
#    Given there are the following PKIs:
#      | name         | cert_filename    |
#      | TEST_PKI_ONE | test_pki_one.crt |
#    Given the following certificates are defined in metadata:
#      | entity_id | key_name  | pki          | status  |
#      | foo       | foo_key_1 | TEST_PKI_ONE | good    |
#      | foo       | foo_key_2 | TEST_PKI_ONE | good    |
#      | bar       | bar_key_1 | TEST_PKI_ONE | near_expiry |
#    Given there is metadata at http://localhost:53011
#    When I run `sensu-metadata-expiry-check -h http://localhost:53011 -w 28 -c 14`
#    Then the exit status should be 1
#    Then the output should match:
#    """
#    metadata_expiry_check WARNING: The certificate named bar_key_1 for the entity 'bar' has a status of NEAR EXPIRY (.*)
#
#    """
#
#  Scenario: Check metadata with expired certificate
#    Given there are the following PKIs:
#      | name         | cert_filename    |
#      | TEST_PKI_ONE | test_pki_one.crt |
#    Given the following certificates are defined in metadata:
#      | entity_id | key_name  | pki          | status  |
#      | foo       | foo_key_1 | TEST_PKI_ONE | good    |
#      | foo       | foo_key_2 | TEST_PKI_ONE | good    |
#      | bar       | bar_key_1 | TEST_PKI_ONE | almost_expired |
#    Given there is metadata at http://localhost:53012
#    When I run `sensu-metadata-expiry-check -h http://localhost:53012 -w 28 -c 14`
#    Then the exit status should be 2
#    Then the output should match:
#    """
#    metadata_expiry_check CRITICAL: The certificate named bar_key_1 for the entity 'bar' has a status of ALMOST EXPIRED (.*)
#
#    """
#  Scenario: Check metadata with expired certificate
#    Given there are the following PKIs:
#      | name         | cert_filename    |
#      | TEST_PKI_ONE | test_pki_one.crt |
#    Given the following certificates are defined in metadata:
#      | entity_id | key_name  | pki          | status  |
#      | foo       | foo_key_1 | TEST_PKI_ONE | good    |
#      | foo       | foo_key_2 | TEST_PKI_ONE | good    |
#      | bar       | bar_key_1 | TEST_PKI_ONE | expired |
#    Given there is metadata at http://localhost:53013
#    When I run `sensu-metadata-expiry-check -h http://localhost:53013 -w 28 -c 14`
#    Then the exit status should be 2
#    Then the output should match:
#      """
#      metadata_expiry_check CRITICAL: The certificate named bar_key_1 for the entity 'bar' has a status of EXPIRED (.*)
#
#      """
#  Scenario: Check metadata with expired certificate and certificate close to expiry
#    Given there are the following PKIs:
#      | name         | cert_filename    |
#      | TEST_PKI_ONE | test_pki_one.crt |
#    Given the following certificates are defined in metadata:
#      | entity_id | key_name  | pki          | status  |
#      | foo       | foo_key_1 | TEST_PKI_ONE | good    |
#      | foo       | foo_key_2 | TEST_PKI_ONE | near_expiry |
#      | bar       | bar_key_1 | TEST_PKI_ONE | expired |
#    Given there is metadata at http://localhost:53014
#    When I run `sensu-metadata-expiry-check -h http://localhost:53014 -w 28 -c 14`
#    Then the exit status should be 2
#    Then the output should match:
#        """
#        metadata_expiry_check CRITICAL: The certificate named bar_key_1 for the entity 'bar' has a status of EXPIRED (.*)
#        The certificate named foo_key_2 for the entity 'foo' has a status of NEAR EXPIRY (.*)
#
#        """
