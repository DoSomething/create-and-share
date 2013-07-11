Given /there is a campaign/ do
  FactoryGirl.create(:campaign)
end


When /I visit the (.*) page/ do |route|
  if route == 'home'
    route = ""
  end
	visit('/' + route)
end

Given /I am logged in/ do
  visit '/login'
  click_link 'log in'
  within '.form-login' do
    find(:id, 'session_username').set 'test@subject.com'
    find(:id, 'login-password').set 'test'
    click_button 'login'
  end
end

Then /the page should not have element (.+)/ do |elements|
	elements.split(", ").each do |element|
		page.should have_no_selector(:css_selector, element)
	end
end

Then /I am on the login form/ do
  visit '/picsforpets'
  click_link 'log in'
end

Then /the page should redirect to the (.*) page/ do |path|
  page.current_path.should eq "/" + path
end

Then /the page should redirect matching (.*)/ do |regex|
  current_path.should match(regex)
end

Then /the page should respond with (\d+)/ do |response|
  page.status_code.should eq response.to_i
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
