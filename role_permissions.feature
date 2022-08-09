Feature: To test role assignments and permissions

  # This feature file assumptions
  #  initial_setup_01.feature was run before this and passed

  @Balance
  @Release2015.2.0
  @PB156264-006
  Scenario: Add and assign site roles to Balance Users in MCCAdmin and check if they have access in Balance
    Given I login to "iMedidata" as user "balancemistuser"
    And I navigate to "MCCAdmin" for study group "Bal_MCC_Integ_E2E" from iMedidata
    And In MCCAdmin I select study "Test_MCC_001" from the study list table
    And In MCCAdmin I add new user to study "Test_MCC_001" using the value below:
      | First     | Last      | Email                          | Environment   | Roles                | Sites           |
      | Balance   | SITECRCBL | balancesitecrcbl@gmail.com     | Development   | balance_crc_blinded  | Balance Site 01 |
    And In MCCAdmin I add new user to study "Test_MCC_001" using the value below:
      | First     | Last      | Email                          | Environment   | Roles                | Sites                           |
      | Balance   | SITECRABL | balancesitecrabl@gmail.com     | Development   | balance_cra_blinded  | Balance Site 02,Balance Site 03 |
    And I logout from "MCCAdmin"
    And I login to "iMedidata" as user "balancesitecrcbl"
    And I take a screenshot
    And I perform actions for invitations in iMedidata using the values below:
      | Name           | Environment | Invitation     |
      | Test_MCC_001   | DEV         | Accept         |
    And I search for study "Test_MCC_001 (DEV)"
    And I take a screenshot
    Then I select app "BalanceValidation" from search results
    And In Balance I verify the "sites" table has contents of:
      | Name            | Number | Country  | Shipping Status |
      | Balance Site 01 | 100    | USA      | Inactive        |
    And In Balance I verify the "Name" column of "sites" table does not contain "Balance Site 02,Balance Site 03"
    And In Balance I follow the iMedidata Logo
    And I logout from "iMedidata"
    When I login to "iMedidata" as user "balancesitecrabl"
    And I take a screenshot
    And I perform actions for invitations in iMedidata using the values below:
      | Name           | Environment | Invitation     |
      | Test_MCC_001   | DEV         | Accept         |
    And I search for study "Test_MCC_001 (DEV)"
    And I take a screenshot
    Then I select app "BalanceValidation" from search results
    And In Balance I verify the "sites" table has contents of:
      | Name            | Number | Country  | Shipping Status |
      | Balance Site 02 | 200    | USA      | Inactive        |
      | Balance Site 03 | 300    | USA      | Inactive        |
    And In Balance I verify the "Name" column of "sites" table does not contain "Balance Site 01"
    And In Balance I follow the iMedidata Logo
    And I logout from "iMedidata"

  @Balance
  @Release2015.2.0
  @PB156264-007
  Scenario: Add and assign depot roles to Balance users in MCCAdmin and check if they have access in Balance
    Given I login to "iMedidata" as user "balancemistuser"
    And In iMedidata I navigate to "MCCAdmin" for study group "Bal_MCC_Integ_E2E"
    And In MCCAdmin I select study "Test_MCC_001" from the study list table
    And In MCCAdmin I add new user to study "Test_MCC_001" using the value below:
      | First     | Last      | Email                          | Environment   | Roles                    |
      | Balance   | SHIPMANUN | balanceshipmanun@gmail.com     | Development   | balance_shipment_man_un  |
    And I logout from "iMedidata"

    When I login to "iMedidata" as user "balanceshipmanun"
    And I take a screenshot
    And I perform actions for invitations in iMedidata using the values below:
      | Name           | Environment | Invitation     |
      | Test_MCC_001   | DEV         | Accept         |
    And I logout from "iMedidata"

    Given I login to "iMedidata" as user "balancemistuser"
    And In iMedidata I navigate to "MCCAdmin" for study group "Bal_MCC_Integ_E2E"
    And In MCCAdmin I select study "Test_MCC_001" from the study list table
    And In MCCAdmin I select environment "Development" from the filter group
    And In MCCAdmin I navigate to "Manage Depots" page
    And In iMedidata I add users "balanceshipmanun@gmail.com" to depot "Depot1"
    And I take a screenshot
    And I logout from "iMedidata"

    When I login to "iMedidata" as user "balanceshipmanun"
    And I search for study "Test_MCC_001 (DEV)"
    And I take a screenshot
    Then I select app "BalanceValidation" from search results
    And In Balance I navigate to the Inventory Overview Page
    And In Balance I verify the "inventory overview" table has contents of:
      | Depot   |
      | Depot1  |
    And In Balance I follow the iMedidata Logo
    And I logout from "iMedidata"

