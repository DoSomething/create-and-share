Feature: Home run
  We need to check the basic flow works.

  Background:
    Given there is a campaign

  Scenario: Show the login form
    When I visit /picsforpets
    Then the page should show Need an account?
    When I click on register
    Then the page should show Already have an account?

  Scenario: Log in
    Given I am on the login form
    When I sign in
    When I visit /picsforpets
    Then the page should show Maryland
