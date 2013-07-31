RSpec.configure do |config|
  config.include Features::CampaignHelpers, type: :feature
  config.include Features::SessionHelpers, type: :feature
  config.include Features::PostHelpers, type: :feature
end