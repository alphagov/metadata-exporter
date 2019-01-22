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
    When I start the prometheus client on port 2020 with metadata on port 53110 with ca test_pki_one.crt
    Then the metrics on port 2020 should contain exactly:
    """
    # TYPE verify_federation_certificate_expiry gauge
    # HELP verify_federation_certificate_expiry The NotAfter date of the given X.509 SAML certificate
    verify_federation_certificate_expiry{entity_id="foo",key_use="encryption",key_name="foo_key_1",serial="2"} (\d+).0
    verify_federation_certificate_expiry{entity_id="foo",key_use="encryption",key_name="foo_key_2",serial="3"} (\d+).0
    verify_federation_certificate_expiry{entity_id="bar",key_use="encryption",key_name="bar_key_1",serial="4"} (\d+).0
    # TYPE verify_federation_certificate_ocsp_success gauge
    # HELP verify_federation_certificate_ocsp_success If an OCSP check of the given X.509 SAML certificate is good \(1\) or bad \(0\)
    verify_federation_certificate_ocsp_success{entity_id="foo",key_use="encryption",key_name="foo_key_1",serial="2"} 1.0
    verify_federation_certificate_ocsp_success{entity_id="foo",key_use="encryption",key_name="foo_key_2",serial="3"} 1.0
    verify_federation_certificate_ocsp_success{entity_id="bar",key_use="encryption",key_name="bar_key_1",serial="4"} 1.0

    """

  Scenario: Check metadata that contains a revoked cert
    Given there are the following PKIs:
      | name         | cert_filename    |
      | TEST_PKI_ONE | test_pki_one.crt |
    Given the following certificates are defined in metadata:
      | entity_id | key_name  | pki          | status |
      | foo       | foo_key_1 | TEST_PKI_ONE | good   |
      | foo       | foo_key_2 | TEST_PKI_ONE | good   |
      | bar       | bar_key_1 | TEST_PKI_ONE | revoked   |
    And there is metadata at http://localhost:53111
    And there is an OCSP responder
    When I start the prometheus client on port 2021 with metadata on port 53111 with ca test_pki_one.crt
    Then the metrics on port 2021 should contain exactly:
    """
    # TYPE verify_federation_certificate_expiry gauge
    # HELP verify_federation_certificate_expiry The NotAfter date of the given X.509 SAML certificate
    verify_federation_certificate_expiry{entity_id="foo",key_use="encryption",key_name="foo_key_1",serial="2"} (\d+).0
    verify_federation_certificate_expiry{entity_id="foo",key_use="encryption",key_name="foo_key_2",serial="3"} (\d+).0
    verify_federation_certificate_expiry{entity_id="bar",key_use="encryption",key_name="bar_key_1",serial="4"} (\d+).0
    # TYPE verify_federation_certificate_ocsp_success gauge
    # HELP verify_federation_certificate_ocsp_success If an OCSP check of the given X.509 SAML certificate is good \(1\) or bad \(0\)
    verify_federation_certificate_ocsp_success{entity_id="foo",key_use="encryption",key_name="foo_key_1",serial="2"} 1.0
    verify_federation_certificate_ocsp_success{entity_id="foo",key_use="encryption",key_name="foo_key_2",serial="3"} 1.0
    verify_federation_certificate_ocsp_success{entity_id="bar",key_use="encryption",key_name="bar_key_1",serial="4"} 0.0

    """

