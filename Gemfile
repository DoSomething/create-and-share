source 'https://rubygems.org'

gem 'rails', '3.2.13'

gem 'pg'
gem 'paperclip'
gem 'httparty'
gem 'simple_form'
gem 'therubyracer'

gem 'gibbon'
gem 'omniauth-facebook'
gem 'newrelic_rpm'
gem 'chronic'

gem 'dalli'
gem 'mailchimp'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'compass-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'headless'
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
  gem 'passenger'
  gem 'spork'

  #guard!
  gem 'guard-rspec'
  gem 'guard-cucumber'
  gem 'guard-livereload'
  gem 'rack-livereload'
  #gem 'guard-compass'
  gem 'guard-spork'
  gem 'guard-passenger'
  gem 'factory_girl_rails', '~> 4.0'
end

gem 'jquery-rails'

gem 'active_model_serializers'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'debugger'
