def login(type)
  if type == :user
    user = FactoryGirl.create(:user)
  elsif type == :admin_user
    user = FactoryGirl.create(:user, :admin)
  end

  visit '/login'
  click_link 'log in'
  fill_in('session_username', with: user.email)
  fill_in('login-password', with: "bohemian_test")
  click_button 'login'
  user
end
