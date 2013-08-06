class CampaignSettings
  cattr_accessor :filters, :facebook, :popups

  @@filters = {}
  @@facebook = {}
  @@popups = {}
  def initialize
  	files = Dir["#{Rails.root}/config/campaigns/*.yml"]
  	files.each do |file|
  	  k = Pathname.new(file).basename.to_s.gsub('.yml', '')
  	  @@filters[k] ||= []
      @@facebook[k] ||= []
      @@popups[k] ||= []

  	  f = YAML::load(File.open(file))
      @@filters[k] = f['filters'] || {}
      @@facebook[k] = f['facebook'] || {}
      @@popups[k] = f['popups'] || {}
  	end
  end
end

settings = CampaignSettings.new
CreateAndShare::Application.config.filters = settings.filters
CreateAndShare::Application.config.facebook = settings.facebook
CreateAndShare::Application.config.popups = settings.popups

if ActiveRecord::Base.connection.table_exists? 'campaigns'
  Campaign.find(:all, :select => 'path').each do |campaign|
    campaign = campaign.path
    %w{stylesheets javascripts}.each do |dir|
      CreateAndShare::Application.config.assets.precompile += ["app/assets/#{dir}/campaigns/#{campaign}/*.css", "app/assets/#{dir}/campaigns/#{campaign}/*.js"]
    end
  end
end