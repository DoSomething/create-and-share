Dir['./features/*.rb'].each { |file| require file }
Dir['./campaigns/*.rb'].each { |file| require file }
# RSpec.configure do |config|
#   config.include Features::CampaignHelpers, type: :feature
#   config.include Features::SessionHelpers, type: :feature
#   config.include Features::PostHelpers, type: :feature
# end
