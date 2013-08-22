filters = {}
facebook = {}
popups = {}
home = {}
stats = {}
files = Dir["#{Rails.root}/config/campaigns/*.yml"]
files.each do |file|
  k = Pathname.new(file).basename.to_s.gsub('.yml', '')
  filters[k] ||= []
  facebook[k] ||= []
  popups[k] ||= []

  f = YAML::load(File.open(file))
  home[k] = f['home'] || {}
  filters[k] = f['filters'] || {}
  facebook[k] = f['facebook'] || {}
  popups[k] = f['popups'] || {}
  stats[k] = f['stats'] || {}
end

CreateAndShare::Application.config.home = home
CreateAndShare::Application.config.filters = filters
CreateAndShare::Application.config.facebook = facebook
CreateAndShare::Application.config.popups = popups
CreateAndShare::Application.config.stats = stats

if ActiveRecord::Base.connection.table_exists? 'campaigns'
  Campaign.find(:all, :select => 'path').each do |campaign|
    campaign = campaign.path
    %w{stylesheets javascripts}.each do |dir|
      CreateAndShare::Application.config.assets.precompile += ["app/assets/#{dir}/campaigns/#{campaign}/*.css", "app/assets/#{dir}/campaigns/#{campaign}/*.js"]
    end
  end
end