# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'vtapp'


#############################################################
#   Servers
#############################################################
# set :user, 'deploy'
# set :scm_passphrase, 'vinsol'
set :use_sudo, true
 
# set :ssh_options, { :forward_agent => true }
 
# set :domain, "106.185.48.38"
# server domain, :app, :web
# role :db, domain, :primary => true
 
#############################################################
#   Git
#############################################################
set :repo_url, 'git@bitbucket.org:tanmay3011/vtapp.git'
set :deploy_via, :remote_cache
# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# role :web, "106.185.48.38"                          # Your HTTP server, Apache/etc
# role :app, "106.185.48.38"                          # This may be the same as your `Web` server
set :linked_dirs, %w{tmp/pids}

set :linked_files, %w{config/database.yml}
SSHKit.config.command_map[:rake]  = "bundle exec rake" #8
SSHKit.config.command_map[:rails] = "bundle exec rails"


namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, release_path.join('tmp/restart.txt')
    end
    # invoke 'delayed_job:restart'
  end
  after :publishing, 'deploy:restart'
  after :finishing, 'deploy:cleanup'
end