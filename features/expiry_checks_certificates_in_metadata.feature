Feature: expiry of certificates in metadata is checked

  In order to gurantee the health of the federation,
  As a service manager,
  I want to be alerted if our metadata contains certificates that will expire soon

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
    And there is metadata at http://localhost:53010
    When I successfully run `sensu-metadata-expiry-check -h http://localhost:53010 -w 28 -c 14`
    Then the output should contain exactly:
    """
    metadata_expiry_check OK: no certificates near expiry

    """

  Scenario: Check metadata with certificate close to expiry
    Given there are the following PKIs:
      | name         | cert_filename    |
      | TEST_PKI_ONE | test_pki_one.crt |
    Given the following certificates are defined in metadata:
      | entity_id | key_name  | pki          | status  |
      | foo       | foo_key_1 | TEST_PKI_ONE | good    |
      | foo       | foo_key_2 | TEST_PKI_ONE | good    |
      | bar       | bar_key_1 | TEST_PKI_ONE | near_expiry |
    Given there is metadata at http://localhost:53011
    When I run `sensu-metadata-expiry-check -h http://localhost:53011 -w 28 -c 14`
    Then the exit status should be 1
    Then the output should match:
    """
    metadata_expiry_check WARNING: The certificate named bar_key_1 for the entity 'bar' has a status of NEAR EXPIRY (.*)

    """

  Scenario: Check metadata with expired certificate
    Given there are the following PKIs:
      | name         | cert_filename    |
      | TEST_PKI_ONE | test_pki_one.crt |
    Given the following certificates are defined in metadata:
      | entity_id | key_name  | pki          | status  |
      | foo       | foo_key_1 | TEST_PKI_ONE | good    |
      | foo       | foo_key_2 | TEST_PKI_ONE | good    |
      | bar       | bar_key_1 | TEST_PKI_ONE | almost_expired |
    Given there is metadata at http://localhost:53012
    When I run `sensu-metadata-expiry-check -h http://localhost:53012 -w 28 -c 14`
    Then the exit status should be 2
    Then the output should match:
    """
    metadata_expiry_check CRITICAL: The certificate named bar_key_1 for the entity 'bar' has a status of ALMOST EXPIRED (.*)

    """
  Scenario: Check metadata with expired certificate
      Given there are the following PKIs:
        | name         | cert_filename    |
        | TEST_PKI_ONE | test_pki_one.crt |
      Given the following certificates are defined in metadata:
        | entity_id | key_name  | pki          | status  |
        | foo       | foo_key_1 | TEST_PKI_ONE | good    |
        | foo       | foo_key_2 | TEST_PKI_ONE | good    |
        | bar       | bar_key_1 | TEST_PKI_ONE | expired |
      Given there is metadata at http://localhost:53013
      When I run `sensu-metadata-expiry-check -h http://localhost:53013 -w 28 -c 14`
      Then the exit status should be 2
      Then the output should match:
      """
      metadata_expiry_check CRITICAL: The certificate named bar_key_1 for the entity 'bar' has a status of EXPIRED (.*)

      """
  Scenario: Check metadata with expired certificate and certificate close to expiry
      Given there are the following PKIs:
        | name         | cert_filename    |
        | TEST_PKI_ONE | test_pki_one.crt |
      Given the following certificates are defined in metadata:
        | entity_id | key_name  | pki          | status  |
        | foo       | foo_key_1 | TEST_PKI_ONE | good    |
        | foo       | foo_key_2 | TEST_PKI_ONE | near_expiry |
        | bar       | bar_key_1 | TEST_PKI_ONE | expired |
      Given there is metadata at http://localhost:53014
        When I run `sensu-metadata-expiry-check -h http://localhost:53014 -w 28 -c 14`
        Then the exit status should be 2
        Then the output should match:
        """
        metadata_expiry_check CRITICAL: The certificate named bar_key_1 for the entity 'bar' has a status of EXPIRED (.*)
        The certificate named foo_key_2 for the entity 'foo' has a status of NEAR EXPIRY (.*)
        
        """
