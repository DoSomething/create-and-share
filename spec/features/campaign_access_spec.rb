require 'spec_helper'

feature 'View campaigns gated / ungated' do
  background do
    @gated = FactoryGirl.create(:campaign, gated: true)
    @ungated = FactoryGirl.create(:campaign, gated: false)
  end

  scenario 'user is logged in' do
    login(:user)
    visit '/'
    click_link @gated.title
    page.should have_content 'Create and Share index page'
    visit '/'
    click_link @ungated.title
    page.should have_content 'Create and Share index page'
  end

  scenario 'user is not logged in' do
    visit '/'
    click_link @gated.title
    page.should have_content 'you must be logged in'
    visit '/'
    click_link @ungated.title
    page.should have_content 'Create and Share index page'
  end
end