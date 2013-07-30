Given /I do not have a DoSomething account/ do
  @nUsers = User.all.count
  @email = 'void-' + Time.now.to_i.to_s + '@dosomething.org'
  @password = "dummy"
  Services::Auth.check_exists(@email).first.should eq nil
end

Given /I have a DoSomething account(.*)/ do |fail|
  @nUsers = User.all.count
  @email = "test@subject.com"
  if fail == " but I mess up my password"
    @password = "fail"
  else
    @password = "test"
  end
  Services::Auth.check_exists(@email).first.should_not eq nil
end

Given /I have not used CAS before/ do
  User.find_by_email(@email).should eq nil
  Services::Auth.check_exists(@email).first.should_not eq nil
end

Given /I have used CAS before/ do
  FactoryGirl.create(:user)
  @nUsers = User.all.count
  User.find_by_email(@email).should_not eq nil
  Services::Auth.check_exists(@email).first.should_not eq nil
end

When /I try to login/ do
  click_link 'log in'
  fill_in "session_username", :with => @email
  fill_in "login-password", :with => @password
  click_button 'login'
end

When /I try to register/ do
  fill_in "session_first", :with => "Dummy"
  fill_in "session_last", :with => "Dummy"
  fill_in "session_email", :with => @email
  fill_in "session_cell", :with => "123-456-7890"
  fill_in "session_password", :with => "dummy"
  fill_in "session_month", :with => "10"
  fill_in "session_day", :with => "05"
  fill_in "session_year", :with => "2000"
  click_button 'register'
end

When /I login with (.*)/ do |provider|
  OmniAuth.config.add_mock(:facebook, {
    :provider => 'facebook',
    :uid => '1234567',
    :extra => {
      :raw_info => {
        :id => "1234567",
        :email => @email,
        :first_name => "Dummy",
        :last_name => "Dummy"
      }
    }
  })
  visit "/auth/#{provider.downcase}"
end

Then /I should be on the home page/ do
  page.should have_content "Share shelter pets with friends."
end

Then /a new CAS account should not be created/ do
  User.all.count.should eq @nUsers
end

Then /a new CAS account should be created/ do
  User.last.email.should eq @email
  User.all.count.should eq @nUsers + 1
end

Then /a new DoSomething account should be created/ do
  Services::Auth.check_exists(@email).first.should_not eq nil
end