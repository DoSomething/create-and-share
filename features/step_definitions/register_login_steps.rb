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