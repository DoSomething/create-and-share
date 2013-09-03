set :application, "Create and Share"
set :repository,  "git@cas:DoSomething/create-and-share.git"
set :branch, 'master'

set :gateway, 'admin.dosomething.org:38383'
server 'campaigns.dosomething.org', :app, :web, :db
set :port, '38383'
set :user, 'dosomething'
set :password, ENV['DS_DEPLOY_PASS']
ssh_options[:keys] = [ENV['CAP_PRIVATE_KEY']]

set :deploy_to, '/var/www/campaigns'

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
    run "cd #{release_path} && bundle exec rake db:migrate"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
  # task :refresh_styles do
  #   run "cd #{release_path}; RAILS_ENV=production bundle exec rake paperclip:refresh:missing_styles"
  # end
end

before 'deploy:assets:precompile', 'deploy:bundle'
after 'deploy:bundle', 'deploy:db'
#after 'deploy:update_code', 'deploy:rspec'
#after 'deploy:update_code', 'deploy:refresh_styles'