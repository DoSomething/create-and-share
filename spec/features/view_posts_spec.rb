require 'spec_helper'

feature 'View posts' do
  let(:campaign) { FactoryGirl.create(:campaign) }

  background do
    @post1 = FactoryGirl.create(:post, campaign_id: campaign.id)
    @post2 = FactoryGirl.create(:post, campaign_id: campaign.id)
    login(:user)
  end

  scenario 'User can see a campaigns posts' do
    visit "/#{campaign.path}"
    page.should have_content @post1.name
    page.should have_content @post2.name
  end

  scenario 'User can view a single post' do
    visit "/#{campaign.path}"
    click_link @post1.name
    page.should have_content @post1.story
    page.should_not have_content @post2.name
  end

  scenario 'User can scroll to see more posts', js:true do
    8.times do
      FactoryGirl.create(:post, campaign_id: campaign.id)
    end
    @topPost = FactoryGirl.create(:post, campaign_id: campaign.id)
    visit "/#{campaign.path}"
    page.should_not have_content @post1.name
    page.execute_script "window.scrollBy(0,10000)"
    page.should have_css ".id-#{@post1.id}"
    page.should have_content @post1.name.upcase
  end
end