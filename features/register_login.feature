Feature: Home run
  We need to confirm that we can login / register.

  Background:
    Given there is a campaign

  @logreg
  @login
  @javascript
  Scenario: Fail Log in
    When I visit /login
    When I click on log in
    Then the page should show Need an account?
    When I fill in #session_username with blahblahblah
    When I fill in #login-password with blahblahblah
    When I click element #btn-login
    Then the page should show INVALID USERNAME / PASSWORD

  @logreg
  @login
  @javascript
  Scenario: Pass Log In
    When I visit /login
    When I click on log in
    Then the page should show Need an account?
    When I fill in #session_username with bohemian_test
    When I fill in #login-password with bohemian_test
    When I click element #btn-login
    When I visit /picsforpets
    Then the page should show Maryland

  @logreg
  @register
  @javascript
  Scenario: Fail register
    When I visit /login
    Then the page should show Already have an account?
    When I fill in #session_first with Test
    When I fill in #session_last with Test
    When I fill in #session_email with mchittenden@dosomething.org
    When I fill in #session_cell with 999-999-9999
    When I fill in #session_password with abc123
    When I fill in #session_month with 10
    When I fill in #session_day with 05
    When I fill in #session_year with 2000
    When I click element #btn-register
    Then the page should show A USER WITH THAT ACCOUNT ALREADY EXISTS

  @logreg
  @register
  @javascript
  Scenario: Pass register
    When I visit /login
    Then the page should show Already have an account?
    When I fill in #session_first with Test
    When I fill in #session_last with Test
    When I fill in the email field
    When I fill in #session_cell with 999-999-9999
    When I fill in #session_password with abc123
    When I fill in #session_month with 10
    When I fill in #session_day with 05
    When I fill in #session_year with 2000
    When I click element #btn-register
    When I visit /picsforpets
    Then the page should show Maryland
