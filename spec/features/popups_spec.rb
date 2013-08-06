require 'spec_helper'

feature 'Popups occur when user shares or votes', js:true do
  let(:campaign) { FactoryGirl.create(:campaign, path: "picsforpets") }

  background do
    @user = login(:user)
    @posts = []
    5.times do
      @posts << FactoryGirl.create(:post, campaign_id: campaign.id)
    end
    visit "/#{campaign.path}"
  end

  scenario 'One action does not do anything' do
    within(:css, ".id-#{@posts[0].id}") do
      find(:css, '.thumbs-up').click
      page.should_not have_content("HI!")
    end
  end

  scenario 'Five actions trigger a popup' do
    @posts.each do |post|
      within(:css, ".id-#{post.id}") do
        find(:css, '.thumbs-up').click
      end
    end
    page.should have_content("HI!")
  end
end