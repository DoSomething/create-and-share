class ApplicationController < ActionController::Base
  protect_from_forgery

  include ApplicationHelper

  # Handy little method that renders the "not found" message, instead of an error.
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # Not found message.
  def record_not_found
    render 'not_found'
  end

  # Confirms that the user is authenticated.  Redirects to root (/) if so.
  # See SessionsController, line 5
  def is_authenticated
    if authenticated?
      redirect_to :root
    end
  end

  # Checks if a user is *not* authenticated.  This is bypassed by using the JSON format,
  # or sending a :bypass parameter through the route (not applicable for standard users --
  # :bypass needs to be sent directly from code.)
  def is_not_authenticated
    unless authenticated? || request.format.symbol == :json || params[:bypass] === true
      session[:source] = request.path
      redirect_to :login
      false
    end
  end

  # Checks if a user is an administrator.
  def admin
    unless admin? || request.format.symbol == :json || params[:bypass] === true
      flash[:error] = "error: please login as admin to view this page"
      if authenticated?
        reset_session
        flash[:error] = "error: you have been logged out - please login as admin to view this page"
      end
      session[:source] = request.path
      redirect_to :login
      false
    end
  end

  # Verifies an API key for GET/POST/etc. requests.  Must be a valid API key found in the
  # api_keys table.
  def verify_api_key
    # Confirm that it's a json request.  This is irrelevant otherwise.
    if request.format.symbol == :json
      # We must have a key, either way.  If no key, pass forbidden response.
      if params[:key].nil?
        render :json => { :errors => "Invalid API key." }, :status => :forbidden
      else
        # Find by key
        @key = ApiKey.find_by_key(params[:key])
        if @key.nil?
          # Throw error if no key found.
          render :json => { :errors => "Invalid API key." }, :status => :forbidden
        end
      end
    end
  end

  # Fixes a bug with the flashbag.
  alias :std_redirect_to :redirect_to
  def redirect_to(*args)
    flash.keep
    std_redirect_to *args
  end
end
