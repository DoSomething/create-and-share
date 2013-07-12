Feature: Registration and login
  In order to gate the site
  As an administrator of the site
  I want users to be able to register and login

  Scenario: Failed registration
    Given I have a DoSomething account
    When I visit the login page
    And I try to register
    Then the page should show A user with that account already exists.
    And a new CAS account should not be created

  Scenario: Successful registration
    Given I do not have a DoSomething account
    When I visit the login page
    And I try to register
    Then I should be on the home page
    And a new DoSomething account should be created
    And a new CAS account should be created

  Scenario: Failed login without a DoSomething account
    Given I do not have a DoSomething account
    When I visit the login page
    And I try to login
    Then the page should show Invalid username / password.
    And a new CAS account should not be created

  Scenario: Failed login with a DoSomething account
    Given I have a DoSomething account but I mess up my password
    When I visit the login page
    And I try to login
    Then the page should show Invalid username / password.
    And a new CAS account should not be created

  Scenario: Successful login having not used CAS before
    Given I have a DoSomething account
    And I have not used CAS before
    When I visit the login page
    And I try to login
    Then I should be on the home page
    And a new CAS account should be created

  Scenario: Successful login having used CAS before
    Given I have a DoSomething account
    And I have used CAS before
    When I visit the login page
    And I try to login
    Then I should be on the home page
    And a new CAS account should not be created

  Scenario: Successful Facebook login without a DoSomething account
    Given I do not have a DoSomething account
    When I visit the login page
    And I login with Facebook
    Then I should be on the home page
    And a new DoSomething account should be created
    And a new CAS account should be created

  Scenario: Successful Facebook login having not used CAS before
    Given I have a DoSomething account
    And I have not used CAS before
    When I visit the login page
    And I login with Facebook
    Then I should be on the home page
    And a new CAS account should be created

  Scenario: Successful Facebook login having used CAS before
    Given I have a DoSomething account
    And I have used CAS before
    When I visit the login page
    And I login with Facebook
    Then I should be on the home page
    And a new CAS account should not be created

