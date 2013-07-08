When /I visit (.*)/ do |route|
  visit(route)
end

Then /the page should redirect to (.*)/ do |path|
  page.current_path.should eq path
end

Then /the page should redirect matching (.*)/ do |regex|
  current_path.should match(regex)
end

Then /the page should respond with (\d+)/ do |response|
  page.status_code.should eq response.to_i
end

When /I fill out the image field/ do
  within '.form-submit' do
    find(:id, 'post_image').click
    find(:id, 'post_image').set Rails.root.to_s + '/spec/mocks/ruby.png'
    find(:id, 'post_image').click
  end
  find(:id, 'crop-button').click
end

When /I fill out the rest of the form and submit/ do
  find(:id, 'post_name').set 'Spot'
  find(:xpath, '//*[@id="post_animal_type"]/option[2]').click
  find(:id, 'post_city').set 'Pittsburgh'
  find(:id, 'post_shelter').set 'Shelter'
  find(:xpath, '//*[@id="post_state"]/option[16]').click

  click_button 'Submit'
end

Given /there is a post/ do
  post = FactoryGirl.create(:post)
end