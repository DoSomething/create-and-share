class ApplicationController < ActionController::Base
  protect_from_forgery

  include ApplicationHelper

  # Handy little method that renders the "not found" message, instead of an error.
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  before_filter :find_view_path
  def find_view_path
    if !get_campaign.nil?
      prepend_view_path 'app/views/campaigns/' + get_campaign.path
    end
  end

  # Not found message.
  def record_not_found
    render 'not_found'
  end

  def get_campaign_from_url(path)
    match = path.match(/^https?\:\/\/[^\/]+\/(?<campaign>[^\/]+)/i)
    if match && !match['campaign'].nil?
      return match['campaign']
    end

    nil
  end

  # Confirms that the user is authenticated.  Redirects to root (/) if so.
  # See SessionsController, line 5
  def is_authenticated
    campaign = get_campaign
    params[:campaign] = campaign

    if authenticated? || campaign && !campaign.is_gated?(params, session)
      if campaign && campaign.path
        redirect_to root_path(:campaign_path => campaign.path)
      else
        redirect_to '/'
      end
    end
  end

  # Checks if a user is *not* authenticated.
  def is_not_authenticated
    campaign = get_campaign
    params[:campaign] = campaign

    unless authenticated? || request.format.symbol == :json || campaign && !campaign.is_gated?(params, session)
      flash[:error] = "you must be logged in to see that"
      session[:source] = request.path
      if campaign && campaign.path
        redirect_to "/#{campaign.path}/login"
      else
        redirect_to '/login'
      end
      false
    end
  end

  # Checks if a user is an administrator.
  def admin
    unless admin? || request.format.symbol == :json
      flash[:error] = "please login as admin to view this page"
      if authenticated?
        reset_session
        flash[:error] = "you have been logged out - please login as admin to view this page"
      end

      session[:source] = request.path
      redirect_to '/login'
      false
    end
  end

  # Verifies an API key for GET/POST/etc. requests.  Must be a valid API key found in the
  # api_keys table.
  def verify_api_key
    # Confirm that it's a json request.  This is irrelevant otherwise.
    if request.format.symbol == :json
      # We must have a key, either way.  If no key, pass forbidden response.
      if params[:key].nil? && (request.env['REQUEST_URI'] =~ Regexp.new(request.env['HTTP_HOST'])).nil?
        render :json => { :errors => "Invalid API key." }, :status => :forbidden
      else
        if (request.env['REQUEST_URI'] =~ Regexp.new(request.env['HTTP_HOST'])).nil?
          # Find by key
          @key = ApiKey.find_by_key(params[:key])
          if @key.nil?
            # Throw error if no key found.
            render :json => { :errors => "Invalid API key." }, :status => :forbidden
          end
        end
      end
    end
  end

  def get_popup
    get_campaign
    action_count = User.find_by_uid(session[:drupal_user_id]).action_count(@campaign.id)
    if Rails.application.config.popups[@campaign.path]
      Rails.application.config.popups[@campaign.path].each do |count, template|
        if count == action_count
          return template
        end
      end
    end
    ""
  end
end
