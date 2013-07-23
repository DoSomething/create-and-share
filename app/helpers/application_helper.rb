module ApplicationHelper
  # Get standard states array.
  def get_states
    { :AL => 'Alabama', :AK => 'Alaska', :AS => 'American Samoa', :AZ => 'Arizona', :AR => 'Arkansas', :CA => 'California', :CO => 'Colorado', :CT => 'Connecticut', :DE => 'Delaware', :DC => 'District of Columbia', :FL => 'Florida', :GA => 'Georgia', :GU => 'Guam', :HI => 'Hawaii', :ID => 'Idaho', :IL => 'Illinois', :IN => 'Indiana', :IA => 'Iowa', :KS => 'Kansas', :KY => 'Kentucky', :LA => 'Louisiana', :ME => 'Maine', :MH => 'Marshall Islands', :MD => 'Maryland', :MA => 'Massachusetts', :MI => 'Michigan', :MN => 'Minnesota', :MS => 'Mississippi', :MO => 'Missouri', :MT => 'Montana', :NE => 'Nebraska', :NV => 'Nevada', :NH => 'New Hampshire', :NJ => 'New Jersey', :NM => 'New Mexico', :NY => 'New York', :NC => 'North Carolina', :ND => 'North Dakota', :MP => 'Northern Marianas Islands', :OH => 'Ohio', :OK => 'Oklahoma', :OR => 'Oregon', :PW => 'Palau', :PA => 'Pennsylvania', :PR => 'Puerto Rico', :RI => 'Rhode Island', :SC => 'South Carolina', :SD => 'South Dakota', :TN => 'Tennessee', :TX => 'Texas', :UT => 'Utah', :VT => 'Vermont', :VI => 'Virgin Islands', :VA => 'Virginia', :WA => 'Washington', :WV => 'West Virginia', :WI => 'Wisconsin', :WY => 'Wyoming' }
  end

  # Is the user authenticated?
  def authenticated?
    (session[:drupal_user_role] && session[:drupal_user_role].values.include?('authenticated user')) ? true : false
  end

  # Is the user an administrator?
  def admin?
    (session[:drupal_user_role] && session[:drupal_user_role].values.include?('administrator')) ? true : false
  end

  # Returns the Facebook App ID, based off of environment.
  # @see /config/initializers/env_variables.rb
  def fb_app_id
    ENV['facebook_app_id']
  end

  # Did the user already submit something?
  def already_submitted?
    user_id = session[:drupal_user_id]
    posts = Post.where(:uid => user_id)
    shares = Share.where(:uid => user_id)

    (user_id && (!shares.nil? && shares.count > 0 || !posts.nil? && posts.count > 0))
  end

  # Prints a friendly error message depending on what path you're at.
  def make_legible(path = params[:filter] ||= request.path)
    # Front page
    if path == 'featured'
      "any featured posts yet"
    # My posts
    elsif path == 'mine'
      "anything by you yet"
    # Everything else
    else
      "anything here"
    end
  end

  def get_campaign
    if params[:campaign_path].nil?
      return nil
    end

    path = params[:campaign_path]

    @campaign = Campaign.where(:path => path).first
  end

  def campaign_stylesheet_link_tag(stylesheet, campaign)
    if campaign && File.exist?(Rails.root.to_s + '/app/assets/stylesheets/campaigns/' + get_campaign.path + '/' + stylesheet + '.sass')
      stylesheet_link_tag 'campaigns/' + get_campaign.path + '/application', :media => "all"
    else
      stylesheet_link_tag stylesheet, :media => "all"
    end
  end

  def campaign_javascript_include_tag(script, campaign)
    if campaign && File.exist?(Rails.root.to_s + '/app/assets/javascripts/campaigns/' + get_campaign.path + '/' + script + '.js')
      javascript_include_tag 'campaigns/' + get_campaign.path + '/application'
    else
      javascript_include_tag script
    end
  end
end
