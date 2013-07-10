Feature: Access Dashboard
	In order to accomplish admin tasks
	As an admin
	I want to be able to access the dashboard

	Background:
		Given there are posts

	Scenario: Visit while not signed in
		When I visit /dashboard
		Then the page should show how it works
		And the page should show please login as admin
		And the page should not show you have been logged out

	Scenario: Visit while signed in but not admin
		When I visit /dashboard
		And I log in as a regular user
		Then the page should show how it works
		And the page should show please login as admin
		And the page should show you have been logged out

	Scenario: Visit while signed in as admin
		When I visit /dashboard
		And I log in as an admin
		Then the page should show Pics for Pets - Dashboard