Feature: Access Dashboard
	In order to accomplish admin tasks
	As an admin
	I want to be able to access the dashboard

	Background:
		Given there is a campaign
		Given there are posts

	@javascript
	Scenario: Visit while not signed in
		When I visit the dashboard page
		Then the page should show how it works
		And the page should show please login as admin
		And the page should not show you have been logged out

	@javascript
	Scenario: Visit while signed in but not admin
		When I visit the dashboard page
		And I log in as a regular user
		When I visit /dashboard
		Then the page should show HOW IT WORKS
		And the page should show PLEASE LOGIN AS ADMIN
		And the page should show YOU HAVE BEEN LOGGED OUT

	@javascript
	Scenario: Visit while signed in as admin
		When I visit the dashboard page
		And I log in as an admin
		When I visit /dashboard
		Then the page should show Pics for Pets - Dashboard
