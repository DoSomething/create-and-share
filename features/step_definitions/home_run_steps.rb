Given /there is a campaign/ do
  FactoryGirl.create(:campaign)
end

When /I click on (.*)/ do |click|
  click_link click
end

When /I click element (.*)/ do |click|
  find(:css_selector, click).click
end

When /I click id (.*)/ do |e|
  find(:id, e).click
end

Then /I am on the login form/ do
  visit '/login'
  click_link 'log in'
end

When /I sign in/ do
  click_link 'log in'
  within '.form-login' do
    find(:id, 'session_username').set 'bohemian_test'
    find(:id, 'login-password').set 'bohemian_test'
    click_button 'login'
  end
end

When /I fill in the email field/ do
  tag = Time.now.to_i.to_s
  find(:id, 'session_email').set 'void-' + tag + '@dosomething.org'
end

Given /I am logged in/ do
  visit '/login'
  click_link 'log in'
  within '.form-login' do
    find(:id, 'session_username').set 'bohemian_test'
    find(:id, 'login-password').set 'bohemian_test'
    click_button 'login'
  end
end

Then /the page should show (.*)/ do |content|
  page.should have_content content
end

Then /the page should not show (.*)/ do |content|
  page.should_not have_content content
end

Then /element (.*) should show (.*)/ do |elm, content|
  e = find(:css_selector, elm)
  e.should have_content content
end

Then /element (.*) should not show (.*)/ do |elm, content|
  e = find(:css_selector, elm)
  e.should_not have_content content
end

When /I fill in (.*) with (.*)/ do |elm, val|
  if val.include? 'mock:'
  	val.gsub(/mock\:/, '')
  	val = Rails.root + '/spec/mocks/' + val
  end

  find(:css_selector, elm).set val
end