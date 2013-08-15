def login(type)
  user = FactoryGirl.build(type)
  visit '/login'
  click_link 'log in'
  fill_in('session_username', with: user.email)
  fill_in('login-password', with: user.is_admin ? "doitdiditdone" : "test")
  click_button 'login'
  user
end
