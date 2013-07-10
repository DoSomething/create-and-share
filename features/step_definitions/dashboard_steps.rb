When /I log in as a regular user/ do
	within '.form-login' do
	  find(:id, 'session_username').set 'test@subject.com'
	  find(:id, 'login-password').set 'test'
	  click_button 'login'
	end
end

When /I log in as an admin/ do
	within '.form-login' do
	  find(:id, 'session_username').set 'fueledbymarvin@gmail.com'
	  find(:id, 'login-password').set 'doitdiditdone'
	  click_button 'login'
	end
end

Given /there are posts/ do
	post = Post.new
	  post.uid = 778374
	  post.adopted = false
	  post.meme_text = 'Bottom text'
	  post.meme_position = 'bottom'
	  post.flagged = false
	  post.image = File.new(Rails.root + 'spec/mocks/ruby.png')
	  post.name = 'Spot the test'
	  post.promoted = false
	  post.share_count = 0
	  post.shelter = 'Cats'
	  post.state = 'PA'
	  post.city = 'Pittsburgh'
	  post.story = "This is a story"
	  post.animal_type = 'cat'
	post.save
end