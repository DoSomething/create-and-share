Feature: Crop image
	We need to be able to crop uploaded images into 1:1 aspect ratio

	Background:
		Given there is a campaign
		Given I am logged in
		And I visit /submit

	@javascript
	Scenario: Successfully crop a picture
		When I open the crop popup
		Then the page should show Squarify your image!

		When I click id crop-button
		Then the page should not have element #crop-overlay, #crop-container
		And the page should have element #preview-img-container
		And image field should be set to ruby.png

	@javascript
	Scenario Outline: Cancel upload
		When I open the crop popup
		And <action>
		Then the page should not have element #crop-overlay, #crop-container, #preview-img-container
		And image field should not be set ""

	Examples:
		| action                   |
		| I click id cancel-button |
		| I click id crop-overlay  |
		| I send escape to "body"  |
