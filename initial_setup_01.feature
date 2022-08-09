Feature: Initial Study Setup for Balance - MCCAdmin Integration testing

  # This feature file assumptions
  #  - Client Division Bal_MCC_Integ_E2E exists with depots and roles


  @Balance
  @Release2015.2.0
  @PB156264-001
  Scenario: Create Study in MCCAdmin for use with Balance
    Given I login to "iMedidata" as user "balancemistuser"
    And In iMedidata I navigate to "MCCAdmin" for study group "Bal_MCC_Integ_E2E"
    And I take a screenshot
    And In MCCAdmin I create a study using the values below:
      | Protocol ID  | Use Protocol ID | Study Name     | Primary Indication       | Secondary Indication | Phase   | Configuration Type          | Test Study |
      | Test_MCC_001 | False           | Test_MCC_001   | Intracerebral Hemorrhage | Acute Pancreatitis   | Phase I | Bal_MCC_Integ_E2E | False      |
    And I take a screenshot
    And I logout from "MCCAdmin"

  @Balance
  @Release2015.2.0
  @PB156264-002
  Scenario: Add user to Balance study as System Administrator
    Given I login to "iMedidata" as user "balancemistuser"
    And In iMedidata I navigate to "MCCAdmin" for study group "Bal_MCC_Integ_E2E"
    And In MCCAdmin I select study "Test_MCC_001" from the study list table
    And In MCCAdmin I add new user to study "Test_MCC_001" using the value below:
      | First     | Last   | Email                          | Environment             | Roles                |
      | Balance   | MIST   | balancemistuser@gmail.com      | Development             | balance_system_admin |
    And I take a screenshot
    And I logout from "MCCAdmin"

  @Balance
  @Release2015.2.0
  @PB156264-003
  Scenario: Add Sites to Balance Study
    Given I login to "iMedidata" as user "balancemistuser"
    And In iMedidata I navigate to "MCCAdmin" for study group "Bal_MCC_Integ_E2E"
    And In MCCAdmin I select study "Test_MCC_001" from the study list table
    And In MCCAdmin I create study site using the values below:
      | Site Name          | Client Division Site Number | Site Number | Street Address | Zip    | City | Country       | State    | Study Environment | Principal Investigator Email   | Principal Investigator First Name | Principal Investigator Last Name | Principal Investigator Role |
      | Balance Site 01    | 100004                      | 100         | 350 Hudson St  | 11222  | NY   | United States | New York | Development       | balancemistuser+pi@gmail.com   | Admin PI                          | User100                          | balance_system_admin        |
    And In MCCAdmin I create study site using the values below:
      | Site Name          | Client Division Site Number | Site Number | Street Address | Zip    | City | Country       | State    | Study Environment | Principal Investigator Email   | Principal Investigator First Name | Principal Investigator Last Name | Principal Investigator Role |
      | Balance Site 02    | 100005                      | 200         | 350 Hudson St  | 11222  | NY   | United States | New York | Development       | balancemistuser+pi@gmail.com   | Admin PI                          | User100                          | balance_system_admin        |
    And In MCCAdmin I create study site using the values below:
      | Site Name          | Client Division Site Number | Site Number | Street Address | Zip    | City | Country       | State    | Study Environment | Principal Investigator Email   | Principal Investigator First Name | Principal Investigator Last Name | Principal Investigator Role |
      | Balance Site 03    | 100006                      | 300         | 350 Hudson St  | 11222  | NY   | United States | New York | Development       | balancemistuser+pi@gmail.com   | Admin PI                          | User100                          | balance_system_admin        |
    And I take a screenshot
    And I logout from "MCCAdmin"

  @Balance
  @Release2015.2.0
  @PB156264-004
  Scenario: Add Depots to Balance Study
    Given I login to "iMedidata" as user "balancemistuser"
    And In iMedidata I navigate to "MCCAdmin" for study group "Bal_MCC_Integ_E2E"
    And In MCCAdmin I select study "Test_MCC_001" from the study list table
    And In MCCAdmin I select environment "Development" from the filter group
    And In MCCAdmin I navigate to "Manage Depots" page
    And In iMedidata I add depots "Depot1,Depot2,Depot3" to the selected study
    And I take a screenshot
    And I logout from "iMedidata"

  @Balance
  @Release2015.2.0
  @PB156264-005
  Scenario: Login to Balance App for Study and do initial setup
    Given I login to "iMedidata" as user "balancemistuser"
    When I search for study "Test_MCC_001 (DEV)"
    And I take a screenshot
    Then I select app "BalanceValidation" from search results
    And I am running the study design wizard having chosen options:
      | Study Design            | Randomization and Supplies Management |
      | Blinding Restrictions   | Yes                                   |
      | Design Setup            | Start from scratch                    |
      | Randomization Type      | Dynamic Allocation                    |
      | Quarantining            | No                                    |
      | Enrollment Caps         | No                                    |
    And I take a screenshot
    And In Balance I add arm "Test Arm 1" with a ratio of 1
    And In Balance I add arm "Test Arm 2" with a ratio of 1
    And In Balance I create randomization factor "Gender" with a weight of 1 and states "Male,Female"
    Then In Balance I set the following randomize and dispense options
      | Rand and Dispense Option | Not Coupled       |
    And I take a screenshot
    When In Balance I create article type with the following attributes:
      | Name | Fixitol 10mg |
    And In Balance I create article type with the following attributes:
      | Name | Fixitol 20mg |
    When In Balance I create a treatment "Treatment 1" with DND of "30" and a composition of "1XFixitol 10mg"
    When In Balance I create a treatment "Treatment 2" with DND of "30" and a composition of "1XFixitol 20mg"
    And I take a screenshot
    When In Balance I create a visit schedule with 5 visits, an offset of 7, start window of 2, end window of 3, and rand visit 2
    And I take a screenshot
    When In Balance I upload packlist "packlist 1" containing 300 items with file path "features/balance/support/packlists/300-items-fixitol.csv"
    And I wait for "5" seconds
    Then In Balance I create lot with options:
      | lot name    | lot one     |
      | expiry date | 31 Dec 2018 |
      | depot       | Depot1      |
    And In Balance I add items "Fixitol 10mg,Fixitol 20mg" to lot "lot one"
    And In Balance I release lot "lot one" with signature "test user"
    And I take a screenshot
    And In Balance I logout

