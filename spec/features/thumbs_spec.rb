require 'spec_helper'

feature 'Voting on a post for the first time', js:true do
  background do
    @user = login(:user)
    @post = FactoryGirl.create(:post)
    @score = @post.plusminus
    visit "/#{@post.campaign.path}"
  end

  scenario 'User can thumbs up a post' do
    within(:css, ".id-#{@post.id}") do
      find(:css, '.thumbs-up').click
      page.should have_content("#{@score + 1}")
    end
  end

  scenario 'User can thumbs down a post' do
    within(:css, ".id-#{@post.id}") do
      find(:css, '.thumbs-down').click
      page.should have_content("#{@score - 1}")
    end
  end
end

### NOT WORKING ###
feature 'Modifying votes on a post', js:true, focus:true do
  background do
    @user = login(:user)
    @post = FactoryGirl.create(:post)
    @user.vote_for(@post)
    @score = @post.plusminus
    visit "/#{@post.campaign.path}"
  end

  scenario 'User can revoke his or her vote' do
    within(:css, ".id-#{@post.id}") do
      find(:css, '.thumbs-up').click
      sleep 5
      page.should have_content("#{@score - 1}")
    end
  end

  scenario 'User can change his or her vote' do
    within(:css, ".id-#{@post.id}") do
      find(:css, '.thumbs-down').click
      sleep 5
      page.should have_content("#{@score - 2}")
    end
  end
end