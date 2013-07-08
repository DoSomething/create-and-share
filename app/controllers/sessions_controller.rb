class SessionsController < ApplicationController
  include Services
  include SessionsHelper

  # Confirm that we're authenticated.
  before_filter :is_authenticated, :only => :new
  layout 'gate'

  def new
    @source = session[:source]
  end

  # GET /login
  def create
    # @TODO - IF AUTHENTICATED, THROW 500

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

    # @TODO - PASSWORD VALIDATION CHECK; MINIMUM CHECK ON LENGTH
    # @TODO - ACCEPTABLE RESPONSE TO USER WHO FAILS TO LOG IN
    # @TODO - STOP REDIRECTING TO /SESSIONS
    # @TODO - KEEP FIELDS POPULATED WHEN CONTROLLER ERRORS OUT
    # @TODO - DATE VALIDATION ON BIRTHDAY

    # If we're attempting to log in...
    if form == 'login'
      # If the user exists...
      if @user = User.exists?(nil, username)
        # Attempt to log them in.
        @u = User.login(session, @user['uid'], username, password)
        if User.logged_in?
          flash[:message] = "You've logged in successfully!"
          source = session[:source] || :root
          session[:source] = nil
          redirect_to source
        else
          # Login fail
          flash[:error] = 'Invalid username / password'
          render :new
        end
      # The user doesn't exist.
      else
        # Attempt to add the user to our database
        @user = User.create({
          :email => username,
          :fbid => 0,
        }, username, password)
        # If we succeed there...
        if User.created?
          # Try to log in...
          @u = User.login(session, @user.uid, username, password)
          if User.logged_in?
            uemail = @u.parsed_response['user']['mail'] || ''
            if uemail.match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i)
              # We can't send mobile commons if we don't have their cell phone #
              handle_mc(uemail, nil)
            end
            # It worked!
            flash[:message] = "You've logged in succesfully!"
            source = :root#session[:source] || :root
            session[:source] = nil
            redirect_to '/'
          else
            # Nope...
            flash[:error] = "Invalid username / password"
            redirect_to :login
          end
        else
          # This would appear if they're trying to login a user that doesn't exist.
          flash[:error] = "Invalid username / password"
          redirect_to :login
        end
      end
    # Otherwise, if we're trying to register...
    elsif form == 'register'
      # Attempt to register the user (this applies here and on Drupal)
      @user = User.register(password, email, 0, first, last, cell, "#{month}/#{day}/#{year}")

      # Did it work?
      if User.registered?
        # Attempt to log them in.
        User.login(session, @user.uid, email, password)

        # Are they logged in?
        if User.logged_in?
          # Yep!
          handle_mc(email, cell)
          flash.now[:message] = 'Super! You\'ve registered successfully' + " #{response}"
          source = :root#session[:source] || :root
          session[:source] = nil
          redirect_to source
        else
          # Nope.
          flash.now[:error] = 'Oh no! Something went wrong while logging you in.  Try again?'
          redirect_to :login
        end
      else
        # Account already exists.
        flash.now[:error] = "A user with that account already exists."
        redirect_to :login
      end
    end
  end

  # Facebook OAuth handler
  def fboauth
    # There's a bunch of data in this variable.
    auth = env['omniauth.auth']['extra']['raw_info']

    # Attempt to authenticate (register / login).
    if handle_auth(auth)
      # It worked.  Bring 'em home.
      flash[:message] = "You are now connected through Facebook!"
      source = session[:source] || :root
      session[:source] = nil
      redirect_to source
    else
      # No work.  Let's ask them to register by other means.
      flash.now[:error] = 'Auth failed! Please try again, or try registering through the form below.'
      render :new
    end
  end

  # GET /logout
  def destroy
    reset_session
    redirect_to :login
  end
end
