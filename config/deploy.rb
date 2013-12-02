require 'rvm/capistrano'

vars_file = File.join(File.expand_path('./config'), 'initializers', 'deploy_vars')
if File.exists? vars_file + '.rb'
  require vars_file
  set :repository,  "git@github.com:DoSomething/create-and-share.git"
  set :scm, :git
  set :branch, "master"
else
  set :repository, "."
  set :scm, :none
  set :deploy_via, :copy
end

set :scm, :git
set :scm_user, ENV['DS_DEPLOY_SCM_USER']
set :scm_passphrase, ENV['DS_DEPLOY_SCM_PASS']

set :gateway, 'admin.dosomething.org:38383'
server 'campaigns.dosomething.org', :app, :web, :db
set :port, '38383'
set :user, 'dosomething'
set :password, ENV['DS_DEPLOY_PASS']
ssh_options[:keys] = [ENV['CAP_PRIVATE_KEY']]
ssh_options[:forward_agent] = true
default_run_options[:pty] = true

set :deploy_to, '/var/www/campaigns'
set :use_sudo, false

namespace :deploy do
  task :start do; end
  task :stop do ; end
  task :bundle do
    run "cd #{release_path} && bundle install --deployment --path=#{deploy_to}/shared"
  end
  # task :rspec do
  #   run "cd #{release_path} && bundle exec rake"
  # end
  task :db do
    run "mkdir -p #{release_path}/tmp/cache/"
    run "cd #{release_path} && bundle exec rake db:migrate"
  end
  # task :install_bundler do
  #   run 'gem install bundler'
  # end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  # task :refresh_styles do
  #   run "cd #{release_path}; RAILS_ENV=production bundle exec rake paperclip:refresh:missing_styles"
  # end
  task :cache_clear do
    run "cd #{release_path} && bundle exec rake cache_clear"
  end
end

before 'deploy:assets:precompile', 'deploy:bundle'
after 'deploy:bundle', 'deploy:db'
after 'deploy:update_code', 'deploy:cache_clear'
# before 'deploy:bundle', 'deploy:install_bundler'
#after 'deploy:update_code', 'deploy:rspec'
#after 'deploy:update_code', 'deploy:refresh_styles'