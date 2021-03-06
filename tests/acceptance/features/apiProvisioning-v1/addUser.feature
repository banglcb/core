@api @provisioning_api-app-required @skipOnLDAP
Feature: add user
  As an admin
  I want to be able to add users
  So that I can give people controlled individual access to resources on the ownCloud server

  Background:
    Given using OCS API version "1"

  @smokeTest
  Scenario: admin creates a user
    Given user "brand-new-user" has been deleted
    When the administrator sends a user creation request for user "brand-new-user" password "%alt1%" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "brand-new-user" should exist
    And user "brand-new-user" should be able to access a skeleton file

  @skipOnOcV10.3
  Scenario Outline: admin creates a user with special characters in the username
    Given user "<username>" has been deleted
    When the administrator sends a user creation request for user "<username>" password "%alt1%" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "<username>" should exist
    And user "<username>" should be able to access a skeleton file
    Examples:
      | username |
      | a@-+_.b  |
      | a space  |

  Scenario: admin tries to create an existing user
    Given user "brand-new-user" has been created with default attributes and skeleton files
    When the administrator sends a user creation request for user "brand-new-user" password "%alt1%" using the provisioning API
    Then the OCS status code should be "102"
    And the HTTP status code should be "200"
    And the API should not return any data

  Scenario: admin tries to create an existing disabled user
    Given user "brand-new-user" has been created with default attributes and skeleton files
    And user "brand-new-user" has been disabled
    When the administrator sends a user creation request for user "brand-new-user" password "%alt1%" using the provisioning API
    Then the OCS status code should be "102"
    And the HTTP status code should be "200"
    And the API should not return any data

  @notToImplementOnOCIS
  Scenario: Admin creates a new user and adds him directly to a group
    Given group "brand-new-group" has been created
    When the administrator sends a user creation request for user "brand-new-user" password "%alt1%" group "brand-new-group" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "brand-new-user" should belong to group "brand-new-group"
    And user "brand-new-user" should be able to access a skeleton file

  Scenario Outline: admin creates a user and specifies a password with special characters
    Given user "brand-new-user" has been deleted
    When the administrator sends a user creation request for user "brand-new-user" password "<password>" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "brand-new-user" should exist
    And user "brand-new-user" should be able to access a skeleton file
    Examples:
      | password                     | comment                               |
      | !@#$%^&*()-_+=[]{}:;,.<>?~/\ | special characters                    |
      | España§àôœ€                  | special European and other characters |
      | नेपाली                       | Unicode                               |

  Scenario: admin creates a user and specifies an invalid password, containing just space
    Given user "brand-new-user" has been deleted
    When the administrator sends a user creation request for user "brand-new-user" password " " using the provisioning API
    Then the OCS status code should be "101"
    And the HTTP status code should be "200"
    And user "brand-new-user" should not exist

  Scenario: admin creates a user and specifies a password containing spaces
    Given user "brand-new-user" has been deleted
    When the administrator sends a user creation request for user "brand-new-user" password "spaces in my password" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "brand-new-user" should exist
    And user "brand-new-user" should be able to access a skeleton file

  Scenario Outline: admin creates a user with username that contains capital letters
    When the administrator sends a user creation request for user "<display-name>" password "%alt1%" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "Brand-New-User" should exist
    And user "BRAND-NEW-USER" should exist
    And user "brand-new-user" should exist
    And user "brand-NEW-user" should exist
    And user "BrAnD-nEw-UsEr" should exist
    And the display name of user "brand-new-user" should be "<display-name>"
    Examples:
      | display-name   |
      | Brand-New-User |
      | BRAND-NEW-USER |
      | brand-new-user |
      | brand-NEW-user |
      | BrAnD-nEw-UsEr |

  Scenario: admin tries to create an existing user but with username containing capital letters
    Given user "brand-new-user" has been created with default attributes and skeleton files
    When the administrator sends a user creation request for user "BRAND-NEW-USER" password "%alt1%" using the provisioning API
    Then the OCS status code should be "102"
    And the HTTP status code should be "200"
    And the API should not return any data

  Scenario Outline: admin creates a user with unusual username
    Given user "<username>" has been deleted
    When the administrator sends a user creation request for user "<username>" password "%alt1%" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "<username>" should exist
    And user "<username>" should be able to access a skeleton file
    Examples:
      | username |
      | user-1   |
      | null     |
      | nil      |
      | 123      |
      | -123     |
      | 0.0      |

  Scenario: subadmin should not be able to create a new user
    Given user "brand-new-user" has been deleted
    And user "subadmin" has been created with default attributes and without skeleton files
    And group "group101" has been created
    And user "subadmin" has been added to group "group101"
    And user "subadmin" has been made a subadmin of group "group101"
    When unauthorized user "subadmin" tries to create new user "brand-new-user" with password "%alt1%" using the provisioning API
    Then the OCS status code should be "106"
    And the HTTP status code should be "200"
    And user "brand-new-user" should not exist

  Scenario: normal user should not be able to create another user
    Given user "brand-new-user" has been deleted
    And user "Alice" has been created with default attributes and without skeleton files
    When unauthorized user "Alice" tries to create new user "brand-new-user" with password "%alt1%" using the provisioning API
    Then the OCS status code should be "997"
    And the HTTP status code should be "401"
    And user "brand-new-user" should not exist

  Scenario: subadmin should be able to create a new user into their group
    Given user "brand-new-user" has been deleted
    And user "subadmin" has been created with default attributes and without skeleton files
    And group "group101" has been created
    And user "subadmin" has been added to group "group101"
    And user "subadmin" has been made a subadmin of group "group101"
    When the groupadmin "subadmin" sends a user creation request for user "brand-new-user" password "%alt1%" group "group101" using the provisioning API
    Then the OCS status code should be "100"
    And the HTTP status code should be "200"
    And user "brand-new-user" should exist

  Scenario: subadmin should not be able to create a new user into other group
    Given user "brand-new-user" has been deleted
    And user "subadmin" has been created with default attributes and without skeleton files
    And group "group101" has been created
    And group "group102" has been created
    And user "subadmin" has been added to group "group101"
    And user "subadmin" has been made a subadmin of group "group101"
    When the groupadmin "subadmin" tries to create new user "brand-new-user" password "%alt1%" in other group "group102" using the provisioning API
    Then the OCS status code should be "105"
    And the HTTP status code should be "200"
    And user "brand-new-user" should not exist