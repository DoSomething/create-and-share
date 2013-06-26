When /I log in as a regular user/ do
	@user = FactoryGirl.create(:user)
	within '.form-login' do
	  find(:id, 'session_username').set 'test@subject.com'
	  find(:id, 'login-password').set 'test'
	  click_button 'login'
	end
end

When /I log in as an admin/ do
	@user = FactoryGirl.create(:user)
	within '.form-login' do
	  find(:id, 'session_username').set 'fueledbymarvin@gmail.com'
	  find(:id, 'login-password').set 'doitdiditdone'
	  click_button 'login'
	end
end