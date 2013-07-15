Feature: Test pages
  We need to check basic routes

  Background:
    Given there is a campaign
    Given there is a post

  Scenario: Routes
    When I visit the home page
    Then the page should redirect to the login page

    When I visit the submit page
    Then the page should redirect to the login page

    When I visit the cats page
    Then the page should redirect to the login page

  @javascript
  Scenario: Submit flow
    Given I am logged in
    When I visit the submit page
    Then the page should show TELL US ABOUT YOUR ANIMAL

    Then element .form-submit should not show Adopt me because...
    Then element .form-submit should not show Text position

    When I fill out the image field

    Then element .form-submit should show Adopt me because...
    Then element .form-submit should show Text position

    When I fill in #post_meme_text with Ruby text
    Then element #upload-preview should show Ruby text

    When I fill out the rest of the form and submit
    Then the page should redirect matching \d+
    Then element .post should show Spot

  Scenario: My Pets
    Given I am logged in
    And I have submitted a post
    When I visit the mypets page
    Then the element .post-list should show Spot the kitten

  Scenario: Filters
    Given I am logged in
    Given I have submitted a post

    When I visit the cats page
    Then the element .post-list should show Spot the kitten

    When I visit the cats-PA page
    Then the element .post-list should show Spot the kitten

    When I visit the PA page
    Then the element .post-list should show Spot the kitten

    When I visit the dogs-PA page
    Then the element .post-list should show We don't have

    When I visit the dogs page
    Then the element .post-list should show We don't have

    When I visit the others-PA page
    Then the element .post-list should show We don't have

    When I visit the others page
    Then the element .post-list should show We don't have
