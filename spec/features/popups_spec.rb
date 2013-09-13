require 'spec_helper'

feature 'Popups occur when user shares or votes', js:true, feature: true do
  background do
    @campaign = FactoryGirl.create(:campaign)
    add_config(@campaign.path)
    @user = login(:user)
    @posts = FactoryGirl.create_list(:post, 2, campaign_id: @campaign.id)
    visit "/#{@campaign.path}"
  end
  after { remove_config(@campaign.path) }

  scenario 'One action does not do anything' do
    within(:css, ".id-#{@posts.first.id}") do
      find(:css, '.thumbs-up').click
      page.should_not have_content("HI!")
    end
  end

  scenario 'Two actions trigger a popup' do
    @posts.each do |post|
      within(:css, ".id-#{post.id}") do
        find(:css, '.thumbs-up').click
      end
    end

    page.should have_content("HI!")
  end
end