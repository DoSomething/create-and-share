class UsersController < ApplicationController
  # GET /submit/guide
  # Saves if a user is going into the submit form.
  before_filter :get_campaign

  def intent
    render :status => :forbidden unless authenticated?

    # Save the intent to related participation.
    user = User.find_by_uid(session[:drupal_user_id])
    if participation = user.participations.where(campaign_id: @campaign.id).first
      participation.intent = true
      participation.save
    end

    # Bring them to the real submit path
    redirect_to :start
  end

  def participation
    render :status => :forbidden unless authenticated?

    user = User.find_by_uid(session[:drupal_user_id])
    if !user.participated?(@campaign.id)
      user.participations.create(intent: false, campaign_id: @campaign.id)
      user.handle_mc(@campaign)
    end

    # Bring them to the real campaign root path or source
    source = session[:source] ||= root_path(campaign_path: @campaign.path)
    session[:source] = nil
    redirect_to source
  end
end
