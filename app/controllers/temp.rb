###########################
### ------------------- ###
### | user.rb methods | ###
### ------------------- ###
###########################

def self.exists?(email)
	if email.nil?
		false
	elsif Services::Auth.check_exists(email).first
		true
	else
		false
	end
end

def self.register(password, email, fbid, first, last, cell, birthday, is_admin = false)
	bday = Date.strptime(birthday, '%m/%d/%Y')
	response = Services::Auth.register(password, email, first, last, cell, bday.month, bday.day, bday.year)
	if response.code == 200 && response.kind_of?(Hash)
		return true
	else
		return false
	end
end

def self.login(session, username, password, cell, fbid)
	if fbid != 0
		uid = Services::Auth.check_admin(username).first['uid']
		if uid
			roles = { 1 => 'administrator', 2 => 'authenticated user' }
		else
			uid = Services::Auth.check_exists(username).first['uid']
			roles = { 1 => 'authenticated user'}
		end
	else
		response = Services::Auth.login(username, password)
		if response.code == 200 && response.kind_of?(Hash)
			uid = response['user']['uid']
			roles = response['user']['roles']
		else
			return false
		end
	end
	user = User.find_by_uid(uid)
	if !user
		user = User.new(:uid => uid, :fbid => fbid, :email => username, :is_admin => roles.values.include?('administrator'))
		email = username
		if !email.match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
			email = nil
		end
		handle_mc(email, cell)
	elsif fbid != 0
		user.fbid = fbid
	end
	user.save
	session[:drupal_user_id] = response['user']['uid']
	session[:drupal_user_role] = response['user']['roles']
	return true
end

##########################################
### ---------------------------------- ###
### | sessions_controller.rb methods | ###
### ---------------------------------- ###
##########################################

def create
	# form
	form     = params[:form]

	# session variable
	sess     = params[:session]

	# login
	username = sess[:username]
	password = sess[:password]

	# registration
	email    = sess[:email]
	first    = sess[:first]
	last     = sess[:last]
	cell     = sess[:cell]
	month    = sess[:month]
	day      = sess[:day]
	year     = sess[:year]

	if form == 'login'
		if User.exists?(username)
			login(form, session, username, password, nil)
		else
			flash[:error] = 'Account doesn\'t exist.'
			redirect_to :login
		end
	elsif form == 'register'
		if User.exists?(email)
			# Account already exists.
			flash[:error] = "A user with that account already exists."
			redirect_to :login
		else
			if User.register(password, email, 0, first, last, cell, "#{month}/#{day}/#{year}")
				login(form, session, email, password, cell)
			else
				# Unforseen error
				flash[:error] = "An error has occurred. Please register again."
			end
		end
	end
end

def fboauth
	# There's a bunch of data in this variable.
	auth = env['omniauth.auth']['extra']['raw_info']

	# Attempt to authenticate (register / login).
	if !User.exists?(auth['email'])
		password = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
		if auth['birthday'].nil?
		  date = Date.parse('5th October 2000')
		else
		  date = Date.strptime(auth['birthday'], '%m/%d/%Y')
		end
		if !User.register(password, auth['email'], auth['first_name'], auth['last_name'], '', date.month, date.day, date.year)
			# Unforseen error
			flash[:error] = "An error has occurred. Please log in again."
		end
	end
	login('facebook', session, auth['email'], nil, nil, auth['id'])
end

private

	def login(form, session, username, password, cell, fbid = 0)
		if User.login(session, username, password, cell, fbid)
			case form
			when 'login'
				flash[:message] = "You've logged in successfully!"
			when 'register'
				flash[:message] = "You've registered successfully!"
			when 'facebook'
				flash[:message] = "You've logged in with Facebook successfully!"
			source = session[:source] || :root
			session[:source] = nil
			redirect_to source
		else
			case form
			when 'login'
				flash[:error] = "Invalid username / password."
			when 'register'
				flash[:error] = "There was an issue logging you in. Please try again."
			when 'facebook'
				flash[:error] = "Facebook authentication failed."
			redirect_to :login
		end
	end