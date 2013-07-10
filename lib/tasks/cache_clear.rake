task :cache_clear => :environment do
  p "Running cache_clear..."
  Rails.cache.clear
  p "Success."
end