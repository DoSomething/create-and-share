Feature: Test pages
  We need to check basic routes

  Background:
    Given there is a campaign
    Given there is a post

  Scenario: Routes
    When I visit /picsforpets
    Then the page should redirect to /login

    When I visit /picsforpets/submit
    Then the page should redirect to /login

    When I visit /picsforpets/cats
    Then the page should redirect to /login

  @javascript
  Scenario: Submit flow
    Given I am logged in
    When I visit /picsforpets/submit
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

    When I visit /picsforpets/mine
    Then the element .post-list should show Spot the kitten

  Scenario: Filters
    Given I am logged in
    Given there is a post

    When I visit /picsforpets/cats
    Then the element .post-list should show Spot the kitten

    When I visit /picsforpets/cats-PA
    Then the element .post-list should show Spot the kitten

    When I visit /picsforpets/PA
    Then the element .post-list should show Spot the kitten

    When I visit /picsforpets/dogs-PA
    Then the element .post-list should show We don't have

    When I visit /picsforpets/dogs
    Then the element .post-list should show We don't have

    When I visit /picsforpets/others-PA
    Then the element .post-list should show We don't have

    When I visit /picsforpets/others
    Then the element .post-list should show We don't have