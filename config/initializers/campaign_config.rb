class CampaignSettings
  cattr_accessor :filters, :facebook

  @@filters = {}
  @@facebook = {}
  def initialize
  	files = Dir["#{Rails.root}/config/campaigns/*.yml"]
  	files.each do |file|
  	  k = Pathname.new(file).basename.to_s.gsub('.yml', '')
  	  @@filters[k] ||= []
      @@facebook[k] ||= []

  	  f = YAML::load(File.open(file))
      @@filters[k] = f['filters']
      @@facebook[k] = f['facebook']
  	end
  end
end

settings = CampaignSettings.new
CreateAndShare::Application.config.filters = settings.filters
CreateAndShare::Application.config.facebook = settings.facebook

if ActiveRecord::Base.connection.table_exists? 'campaigns'
  Campaign.find(:all, :select => 'path').each do |campaign|
    campaign = campaign.path
    %w{stylesheets javascripts}.each do |dir|
      CreateAndShare::Application.config.assets.precompile += ["app/assets/#{dir}/campaigns/#{campaign}/*.css", "app/assets/#{dir}/campaigns/#{campaign}/*.js"]
    end
  end
end
