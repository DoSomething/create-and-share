require 'spec_helper'

feature 'Voting on a post for the first time', js:true, feature: true do
  background do
    @user = login(:user)
    @post = FactoryGirl.create(:post)
    @score = @post.plusminus
    @up = @post.votes_for
    @down = @post.votes_against
    visit "/#{@post.campaign.path}"
  end

  scenario 'User can thumbs up a post' do
    within(:css, ".id-#{@post.id}") do
      find(:css, '.thumbs-up').click
      within(:css, ".count") { page.should have_content("#{@score + 1}") }
      page.execute_script('$(".thumbs-up").trigger("mouseover")')
      within(:css, ".thumbs-up-count") { page.should have_content("#{@up + 1}") }
      page.execute_script('$(".thumbs-down").trigger("mouseover")')
      within(:css, ".thumbs-down-count") { page.should have_content("#{@down}") }
    end
  end

  scenario 'User can thumbs down a post' do
    within(:css, ".id-#{@post.id}") do
      find(:css, '.thumbs-down').click
      within(:css, ".count") { page.should have_content("#{@score - 1}") }
      page.execute_script('$(".thumbs-up").trigger("mouseover")')
      within(:css, ".thumbs-up-count") { page.should have_content("#{@up}") }
      page.execute_script('$(".thumbs-down").trigger("mouseover")')
      within(:css, ".thumbs-down-count") { page.should have_content("#{@down + 1}") }
    end
  end
end

feature 'Modifying votes on a post', js:true, feature: true do
  background do
    @user = login(:user)
    @post = FactoryGirl.create(:post)
    visit "/#{@post.campaign.path}"
    within(:css, ".id-#{@post.id}") do
      find(:css, '.thumbs-up').click
    end
    visit "/"
    @score = @post.plusminus
    @up = @post.votes_for
    @down = @post.votes_against
    visit "/#{@post.campaign.path}"
  end

  scenario 'User can revoke his or her vote' do
    within(:css, ".id-#{@post.id}") do
      find(:css, '.thumbs-up').click
      within(:css, ".count") { page.should have_content("#{@score - 1}") }
      page.execute_script('$(".thumbs-up").trigger("mouseover")')
      within(:css, ".thumbs-up-count") { page.should have_content("#{@up - 1}") }
      page.execute_script('$(".thumbs-down").trigger("mouseover")')
      within(:css, ".thumbs-down-count") { page.should have_content("#{@down}") }
    end
  end

  scenario 'User can change his or her vote' do
    within(:css, ".id-#{@post.id}") do
      find(:css, '.thumbs-down').click
      within(:css, ".count") { page.should have_content("#{@score - 2}") }
      page.execute_script('$(".thumbs-up").trigger("mouseover")')
      within(:css, ".thumbs-up-count") { page.should have_content("#{@up - 1}") }
      page.execute_script('$(".thumbs-down").trigger("mouseover")')
      within(:css, ".thumbs-down-count") { page.should have_content("#{@down + 1}") }
    end
  end
end