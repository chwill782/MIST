Feature: To test site updates/integration in with MCCAdmin

  # This feature file assumptions
  #  initial_setup_01.feature was run before this and passed

  @Balance
  @Release2015.2.0
  @PB163858-01
  Scenario: Update Study Site Number
    Given I login to "iMedidata" as user "balancemistuser"
    And In iMedidata I navigate to "MCCAdmin" for study group "Bal_MCC_Integ_E2E"
    And In MCCAdmin I select study "Test_MCC_001" from the study list table
    And In MCCAdmin I update study site number to "999" for site "Balance Site 01"
    And I take a screenshot
    Then I go to home page
    When I search for study "Test_MCC_001 (DEV)"
    And I take a screenshot
    Then I select app "BalanceValidation" from search results
    And In Balance I navigate to the Manage Sites Page
    And In Balance I verify the "sites" table has contents of:
      | Name            | Number | Country  | Shipping Status |
      | Balance Site 01 | 999    | USA      | Inactive        |
    And I take a screenshot
    And In Balance I follow the iMedidata Logo
    And I logout from "iMedidata"
