class SessionsController < ApplicationController
  include Services

  # Confirm that we're authenticated.
  before_filter :is_authenticated, :only => :new
  layout 'gate'

  def new
    @source = session[:source]
  end

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

  # GET /logout
  def destroy
    reset_session
    redirect_to :login
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

    # Sends MailChimp / Mobile Commons messages to a user.
    #
    # @param string email
    #   The email to send the message to.
    # @param string mobile
    #   A valid phone number to send a txt to.
    ##
    def handle_mc(email = nil, mobile = nil)
      if !email.nil?
        # MailChimp PicsforPets2013
        Services::MailChimp.subscribe(email, 'PicsforPets2013')
        Mailer.signup(email).deliver
      end

      if !mobile.nil?
        # Mobile Commons 158551
        Services::MobileCommons.subscribe(mobile, 158551)
      end
    end
end
