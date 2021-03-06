require 'spec_helper'

feature 'View posts', feature: true do
  let(:campaign) { FactoryGirl.create(:campaign, stat_frequency: 1) }

  background do
    @post1 = FactoryGirl.create(:post, campaign_id: campaign.id)
    @post2 = FactoryGirl.create(:post, campaign_id: campaign.id)
    CreateAndShare::Application.config.stats = { campaign.path => ['This is one stat', 'This is another', 'and another', 'and another'] }
    login(:user)
  end

  describe 'tips' do
    before { visit "/#{campaign.path}" }
    it 'does not show tips if stat_frequency is 0' do
      infrequent = FactoryGirl.create(:campaign)
      visit "/#{infrequent.path}"
      stat = CreateAndShare::Application.config.stats[campaign.path][0]
      page.body.should_not have_content(stat)
    end
    it 'shows 2 tips if stat frequency is 1' do
      page.should have_css('.stat', count: 2)
    end
    # it 'shows 2 tips if stat frequency is 2, and there are 4 posts', js: true do
    #   # Make a campaign with high stat frequency, and appropriate data
    #   very_frequent = FactoryGirl.create(:campaign, stat_frequency: 2)
    #   CreateAndShare::Application.config.stats = { very_frequent.path => ['This is one stat', 'This is another', 'and another', 'and another'] }
    #   FactoryGirl.create_list(:post, 4, campaign_id: very_frequent.id)

    #   # Visit it
    #   visit "/#{very_frequent.path}"

    #   # And expect 2 stats!
    #   page.should have_css('.stat', count: 2)
    # end
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
    Post.stub(:per_page).and_return(2)

    visit "/#{campaign.path}"
    page.should_not have_content @post1.name
    page.execute_script "window.scrollBy(0,10000)"
    page.should have_css ".id-#{@post1.id}"
    page.should have_content @post1.name.upcase
  end
end