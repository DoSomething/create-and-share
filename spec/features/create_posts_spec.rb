require 'spec_helper'

feature 'Submit flow' do
  let(:campaign) { FactoryGirl.create(:campaign) }

  background do
    login(:user)
    visit "/#{campaign.path}"
  end

  scenario 'Start page comes before submit' do
    click_link 'submit your pic'
    page.should have_content 'This is the basic start / submit guide'
    click_link 'submit'
    page.should have_content 'Your image must be a .png, .gif or .jpg'
  end
end

feature 'Create posts' do
  let(:campaign) { FactoryGirl.create(:campaign) }

  background do
    login(:user)
    visit "/#{campaign.path}/submit"
  end

  scenario 'User can create a valid post and see it in mine' do
    post = fill_post_form
    click_button 'Submit'
    page.should have_content post.name
    page.should have_content 'submit another pic'
    page.should have_content 'see your'
    click_link 'see your'
    page.should have_content post.name
  end

  scenario 'User gets errors when submitting an invalid form' do
    click_button 'Submit'
    page.should have_content 'can\'t be blank'
  end
end

feature 'Crop popup', js:true do
  let(:campaign) { FactoryGirl.create(:campaign, gated: false) }

  background do
    visit "/#{campaign.path}/submit"
    open_crop
  end

  scenario 'Crop popup appears' do
    page.should have_content 'Squarify your image!'
  end

  scenario 'Crop popup disabled by click on cancel' do
    find(:id, 'cancel-button').click
    crop_should_disappear
  end

  scenario 'Crop popup disabled by click on overlay' do
    find(:id, 'crop-overlay').click
    crop_should_disappear
  end

  scenario 'Crop popup disabled by click on escape key' do
    find("body").native.send_keys :escape
    crop_should_disappear
  end

  scenario 'Crop successful on crop button' do
    find(:id, 'crop-button').click
    preview_should_appear
  end

  scenario 'Crop successful on enter key' do
    find("body").native.send_keys :return
    preview_should_appear
  end
end