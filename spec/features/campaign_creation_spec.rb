require 'spec_helper'

feature 'Campaign creation' do
  background do
    login(:admin_user)
    visit '/'
  end

  scenario 'Admin can create a valid campaign' do
    page.should have_content 'Add New Campaign'
    click_link 'Add New Campaign'
    campaign = fill_campaign_form
    click_button 'Create Campaign'
    page.should have_content 'We don\'t have anything here yet!'
    visit '/'
    page.should have_content campaign.description
  end

  scenario 'Admin gets errors when submitting an invalid form' do
    click_link 'Add New Campaign'
    click_button 'Create Campaign'
    page.should have_content 'can\'t be blank'
    page.should_not have_content 'We don\'t have anything here yet!'
  end
end

feature 'Campaign creation doesn\'t work for regular users' do
  background do
    login(:user)
    visit '/'
  end

  scenario 'User does not have an add new campaign option' do
    page.should_not have_content 'Add New Campaign'
  end
end