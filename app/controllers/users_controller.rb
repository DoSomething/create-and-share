class UsersController < ApplicationController
  # GET /submit/guide
  # Saves if a user is going into the submit form.
  before_filter :get_campaign

  def intent
    if authenticated?
      # Save the intent to related participation.
      user = User.find_by_uid(session[:drupal_user_id])
      if participation = user.participations.where(campaign_id: @campaign.id).first
        participation.intent = true
        participation.save
      end
    end

    # Bring them to the real submit path
    redirect_to :start
  end

  def participation
    render :status => :forbidden unless authenticated?

    account, participated = Rails.cache.fetch 'user-' + session[:drupal_user_id].to_s + '-participated-in-' + @campaign.id.to_s do
      user = User.find_by_uid(session[:drupal_user_id])
      pc = user.participated?(@campaign.id)

      [user, pc]
    end

    if !participated
      account.participations.create(intent: false, campaign_id: @campaign.id)
      account.handle_mc(@campaign)
    end

    # Bring them to the real campaign root path or source
    source = session[:source] ||= root_path(campaign_path: @campaign.path)
    session[:source] = nil
    redirect_to source
  end
end
