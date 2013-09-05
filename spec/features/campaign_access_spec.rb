require 'spec_helper'

feature 'View campaigns gated / ungated', feature: true do
  background do
    @gated = FactoryGirl.create(:campaign, gated: 'all')
    @gated_submit = FactoryGirl.create(:campaign, gated: 'submit')
    @ungated = FactoryGirl.create(:campaign, gated: '')
  end

  scenario 'user is logged in' do
    login(:user)

    # Fully ungated campaign
    visit '/'
    click_link @ungated.title
    page.should have_content 'Create and Share index page'

    # Fully gated campaign
    visit '/'
    click_link @gated.title
    page.should have_content 'Create and Share index page'

    # Submit-gated campaign
    visit '/'
    click_link @gated_submit.title
    page.should have_content 'Create and Share index page'
    click_link 'submit your pic'
    click_link 'submit'
    page.should have_content 'Upload an image'
  end

  scenario 'user is not logged in' do
    # Fully ungated campaign
    visit '/'
    click_link @ungated.title
    page.should have_content 'Create and Share index page'
    click_link 'submit your pic'
    click_link 'submit'
    page.should have_content 'Upload an image'

    # Fully gated campaign
    visit '/'
    click_link @gated.title
    page.should have_content 'you must be logged in'

    # Submit-gated campaign
    visit '/'
    click_link @gated_submit.title
    page.should have_content 'Create and Share index page'
    click_link 'submit your pic'
    click_link 'submit'
    page.should have_content 'you must be logged in'
  end
end