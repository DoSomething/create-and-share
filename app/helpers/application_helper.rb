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

  # Make the URL human redable
  # @param string path (request.path)
  #   The path that should be made legible.  Should follow these standards:
  #   - /(cat|dog|other)s?
  #   - /[A-Z]{2}
  #   - /(cat|dog|other)s?-[A-Z]{2}
  def make_legible(path = params[:filter] ||= request.path)
    # Dual filter -- animal & state
    if path.match(/(cat|dog|other)s?-[A-Z]{2}/)
      query = path.split('-')
      state = query[1]
      type = query[0]

      states = get_states
      state = states[state.to_sym] || 'that state'

      "any #{type} in #{state} yet"
    # State
    elsif path.match(/[A-Z]{2}/)
      # there is just a state
      states = get_states

      state = states[path.to_sym] || 'that state'

      "anything in #{state} yet" 
    # cat / dog / other
    elsif path.match(/(cat|dog|other)s?/)
      animal = path
      animal << 's' unless animal[-1, 1] == 's'

      "any #{animal} yet"
    # Front page
    elsif path == ''
      "anything yet"
    elsif path == 'featured'
      "any featured pets yet"
    elsif path == 'mine'
      "anything by you yet"
    else
      "anything"
    end
  end

  def campaign_render(**args)
    base = Rails.root.to_s + '/app/views/' + params[:controller]
    if File.exist? base + '/' + params[:campaign] + '/' + args[:template] + '.html.erb'
      render :template => params[:controller] + '/' + params[:campaign] + '/' + args[:template]
    else
      render :template => params[:controller] + '/' + args[:template]
    end
  end

  @campaign = nil
  def get_campaign
    return @campaign unless @campaign.nil?
    return nil if params[:campaign_path].nil?

    path = params[:campaign_path]

    @campaign = Campaign.where(:path => path).first
    @campaign
  end

  def campaign_stylesheet_link_tag(stylesheet)
    if File.exist? Rails.root.to_s + '/app/assets/stylesheets/campaigns/' + get_campaign.path + '/' + stylesheet + '.sass'
      stylesheet_link_tag 'campaigns/' + get_campaign.path + '/application', :media => "all"
    else
      stylesheet_link_tag stylesheet, :media => "all"
    end
  end

  def campaign_javascript_include_tag(script)
    if File.exist? Rails.root.to_s + '/app/assets/javascripts/campaigns/' + get_campaign.path + '/' + script + '.js'
      javascript_include_tag 'campaigns/' + get_campaign.path + '/application'
    else
      javascript_include_tag script
    end
  end
end
