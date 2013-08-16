def add_config(campaign_path)
  # Mock configuration
  f = YAML::load(File.open("#{Rails.root}/spec/mocks/test.yml"))
  filters = f['filters'] || {}
  facebook = f['facebook'] || {}
  popups = f['popups'] || {}
  CreateAndShare::Application.config.filters[campaign_path] = filters
  CreateAndShare::Application.config.facebook[campaign_path] = facebook
  CreateAndShare::Application.config.popups[campaign_path] = popups
  # Create mock popup
  FileUtils.mkdir_p("#{Rails.root}/app/views/campaigns/#{campaign_path}/popups")
  FileUtils.cp "#{Rails.root}/spec/mocks/test.html.erb", "#{Rails.root}/app/views/campaigns/#{campaign_path}/popups/test.html.erb"
end

def remove_config(campaign_path)
  # Reset mock configuration
  CreateAndShare::Application.config.filters[campaign_path] = nil
  CreateAndShare::Application.config.facebook[campaign_path] = nil
  CreateAndShare::Application.config.popups[campaign_path] = nil
  # Remove mock popup
  FileUtils.rmtree "#{Rails.root}/app/views/campaigns/#{campaign_path}"
end

def get_campaign_from_url(path)
  match = path.match(/^https?\:\/\/[^\/]+\/(?<campaign>[^\/]+)/i)
  if match && !match['campaign'].nil?
    return match['campaign']
  end

  nil
end
