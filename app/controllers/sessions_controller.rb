class SessionsController < ApplicationController
  include Services

  before_filter :get_campaign, :only => [:new, :destroy]

  # Confirm that we're authenticated.
  before_filter :is_authenticated, :only => :new
  layout 'gate'

  skip_before_filter :verify_authenticity_token, if: lambda { |p| ['get_auth_bar', 'is_admin'].include?(params[:action]) }

  def new
    @source = session[:source]
  end

  # GET /login
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

    # Campaign information
    campaign = Campaign.find_by_id(sess[:campaign])

    if form == 'log in' # logs in user if he/she exist
      login(false, campaign, form, session, username, password, nil)
    elsif form == 'register' # registers user if they don't exist in the DoSomething drupal database and then logs in him/her
      if User.exists?(email)
        flash[:error] = "A user with that account already exists."
        redirect_to campaign ? "/#{campaign.path}/login" : "/login"
      else
        if User.register(password, email, 0, first, last, cell, "#{month}/#{day}/#{year}")
          login(true, campaign, form, session, email, password, cell)
        else
          flash[:error] = "Invalid information specified. Please try registering again."
          redirect_to campaign ? "/#{campaign.path}/login" : "/login"
        end
      end
    end
  end

  # GET /auth/facebook/callback
  def fboauth
    auth = env['omniauth.auth']['extra']['raw_info'] # data from Facebook
    origin_campaign = get_campaign_from_url(request.env['omniauth.origin'])

    # Try and find the campaign by the path specified in source.
    campaign = Campaign.find_by_path(origin_campaign)

    unless auth['email']
      flash[:error] = "Sorry, we couldn't get your email from Facebook.  Please try registering through the regular form, below."
      redirect_to campaign ? "/#{campaign.path}/login" : "/login"
      return false
    end

    registered = false
    unless User.exists?(auth['email']) # registers user if he/she isn't already in the drupal database
      password = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
      if auth['birthday'].nil? # parse user's birthday or fake it
        date = Date.parse('5th October 2000')
      else
        date = Date.strptime(auth['birthday'], '%m/%d/%Y')
      end
      unless User.register(password, auth['email'], auth['id'], auth['first_name'], auth['last_name'], '', "#{date.month}/#{date.day}/#{date.year}")
        flash[:error] = "An error has occurred. Please log in again."
        redirect_to campaign ? "/#{campaign.path}/login" : "/login"
        return false
      end

      registered = true
    end

    begin
      login(registered, campaign, 'facebook', session, auth['email'], nil, nil, auth['id'])
    rescue
      flash[:error] = "There was a problem while logging you in through Facebook.  Please try registering through the regular form, below."
      redirect_to campaign ? "/#{campaign.path}/login" : "/login"
      return false
    end
  end

  # GET /logout
  def destroy
    reset_session
    redirect_to root_path(:campaign_path => '')
  end

  def get_auth_bar
    @session = session
  end

  def is_admin
    @session = session
  end

  private
    # attempts to log in user and creates a new entry in the rails database if one doesn't exist already
    #
    # @param string form
    #   Specifies from where the method was called so the method can handle errors appropriately
    ##
    def login(registered, campaign, form, session, username, password, cell, fbid = 0)
      if User.login(registered, campaign, session, username, password, cell, fbid)
        case form
        when 'login'
          flash[:message] = "You've logged in successfully!"
        when 'register'
          flash[:message] = "You've registered successfully!"
        when 'facebook'
          flash[:message] = "You've logged in with Facebook successfully!"
        else
          flash[:message] = "You've logged in successfully!"
        end

        if campaign && !User.find_by_uid(session[:drupal_user_id]).participated?(campaign.id)
          redirect_to participation_path(campaign_path: campaign.path)
        else
          source = session[:source] ||= root_path(campaign_path: campaign ? campaign.path : '')
          session[:source] = nil
          redirect_to source
        end
      else
        case form
        when 'login'
          flash[:error] = "Invalid username / password."
        when 'register'
          flash[:error] = "There was an issue logging you in. Please try again."
        when 'facebook'
          flash[:error] = "Facebook authentication failed."
        else
          flash[:error] = "Invalid username / password"
        end

        redirect_to campaign ? "/#{campaign.path}/login" : "/login"
      end
    end
end
