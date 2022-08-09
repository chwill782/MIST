Feature: Balance Smoke Unit Test (Tests Most Balance MIST Steps to assure they are working). Run after code changes.
         Some of these steps might be redundant (Setting up the design multiple times with different options).
         It's mainly to test all the steps.

  Background:
    Given I login to "iMedidata" as user "balancemistuser"
    Then I search for study "MIST Smoke Test - Do Not Alter!"
    Then I select app "BalanceSandbox" from search results

  @Balance
  Scenario: Setup Design Portion in Balance - Utilizing most step definitions
    When In Balance I add arm "Test Arm 1" with a ratio of 2
    When In Balance I add arm "Test Arm 2" with a ratio of 2
    And In Balance I add arm "Test Arm 3" with a ratio of 1
    And In Balance I add arm "Test Arm 4" with a ratio of 1
    And In Balance I update arm "Test Arm 2" ratio to 3
    When In Balance I create randomization factor "Gender" with a weight of 1 and states "Male,Female"
    And In Balance I create randomization factor "Eye Color" with a weight of 3 and states "Blue,Brown,Other"
    And In Balance I update randomization factor "Eye Color" weight to 2
    Then In Balance I set complete randomization probability to 11
    When In Balance I set the following randomize and dispense options
      | Rand and Dispense Option | Forced Allocation |
      | Arm Count                | 3                 |
    # Switch back to Randomization not coupled with Dispensation
    Then In Balance I set the following randomize and dispense options
      | Rand and Dispense Option | Not Coupled       |

    # Treatment Design
    When In Balance I create article type with the following attributes:
      | Name | Fixitol 10mg  |
    And In Balance I create article type with the following attributes:
      | Name        | Fixitol 20mg       |
      | Components  | Bread,Meat,Cheese  |
    And In Balance I create article type with the following attributes:
      | Name        | Pamphlet   |
      | Unnumbered  | Yes        |
      | Open Label  | Yes        |
    When In Balance I create a treatment "Treatment 1" with DND of "30" and a composition of "1XFixitol 10mg,1XPamphlet"
    When In Balance I create a treatment "Treatment 2" with DND of "30" and a composition of "1XFixitol 20mg,1XPamphlet"
    When In Balance I create dosing factor "Weight" with levels "Under 75lbs,75lbs-149lbs,150+ lbs"
    And In Balance I create dosing factor "Height" with levels "Under 5ft,Over 5ft"
    Then In Balance I follow the iMedidata Logo
    And I logout from "iMedidata"


  @Balance
  Scenario: Test By Item Search functionality
    When In Balance I select status "Shipping" on the by item page
    And In Balance I will select Depot fat header selection "Depot1"
    And In Balance I will select Site fat header selection "Test Site 001"
    And In Balance I search by Item Number for item "Item-0"
    And In Balance I search by Article Type for AT number "Testing Purposes"
    And In Balance I search by Sequence Range for sequence starting from "01" and ending with "05"
    And In Balance I search by Expiry Date between "Jan 13 2015" and "Mar 14 2016"
    Then In Balance I follow the iMedidata Logo
    And I logout from "iMedidata"

  @Balance
  Scenario: Delete/Revert all Study Setup
    When In Balance I set second best probability to 10
    When In Balance I delete dosing factor "Weight"
    And In Balance I delete dosing factor "Height"
    And In Balance I delete treatment "Treatment 1"
    And In Balance I delete treatment "Treatment 2"
    And In Balance I delete article type "Fixitol 10mg"
    And In Balance I delete article type "Fixitol 20mg"
    And In Balance I delete article type "Pamphlet"
    And In Balance I delete randomization factor "Eye Color"
    And In Balance I delete randomization factor "Gender"
    And In Balance I delete arm "Test Arm 1"
    And In Balance I delete arm "Test Arm 2"
    And In Balance I delete arm "Test Arm 3"
    And In Balance I delete arm "Test Arm 4"
    Then In Balance I follow the iMedidata Logo
    And I logout from "iMedidata"
