Feature: OCSP checks certificates in metadata

  In order to gurantee the health of the federation,
  As a service manager,
  I want to be alerted if our metadata contains revoked certificates

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
    And there is metadata at http://localhost:53001
    And there is an OCSP responder
    When I successfully run `sensu-metadata-ocsp-check -h http://localhost:53001 --cas test_pki_one.crt`
    Then the output should contain exactly:
    """
    metadata_ocsp_check OK: no revoked certificates

    """

  Scenario: Check unhealthy metadata
    Given there are the following PKIs:
      | name         | cert_filename    |
      | TEST_PKI_ONE | test_pki_one.crt |
    Given the following certificates are defined in metadata:
      | entity_id | key_name  | pki          | status  |
      | foo       | foo_key_1 | TEST_PKI_ONE | good    |
      | foo       | foo_key_2 | TEST_PKI_ONE | good    |
      | bar       | bar_key_1 | TEST_PKI_ONE | revoked |
    Given there is metadata at http://localhost:53000
    And there is an OCSP responder
    When I run `sensu-metadata-ocsp-check -h http://localhost:53000 --cas test_pki_one.crt`
    Then the exit status should be 2
    Then the output should contain exactly:
    """
    metadata_ocsp_check CRITICAL: The certificate named bar_key_1 for the entity 'bar' has an OCSP status of revoked

    """

  Scenario: Check metadata with more than one PKI
    Given there are the following PKIs:
      | name         | cert_filename    |
      | TEST_PKI_ONE | test_pki_one.crt |
      | TEST_PKI_TWO | test_pki_two.crt |
    Given the following certificates are defined in metadata:
      | entity_id | key_name  | pki          | status |
      | foo       | foo_key_1 | TEST_PKI_ONE | good   |
      | foo       | foo_key_2 | TEST_PKI_ONE | good   |
      | bar       | bar_key_1 | TEST_PKI_TWO | good   |
    And there is metadata at http://localhost:53002
    And there is an OCSP responder
    When I successfully run `sensu-metadata-ocsp-check -h http://localhost:53002 --cas test_pki_one.crt,test_pki_two.crt`
    Then the output should contain exactly:
    """
    metadata_ocsp_check OK: no revoked certificates

    """
