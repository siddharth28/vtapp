# # config valid only for Capistrano 3.1
# lock '3.2.1'

# set :application, 'vtapp'


# #############################################################
# #   Servers
# #############################################################
# # set :user, 'deploy'
# # set :scm_passphrase, 'vinsol'
# set :use_sudo, true

# # set :ssh_options, { :forward_agent => true }

# # set :domain, "106.185.48.38"
# # server domain, :app, :web
# # role :db, domain, :primary => true

# #############################################################
# #   Git
# #############################################################
# set :repo_url, 'https://github.com/siddharth28/vtapp.git'
# # Default branch is :master
# # ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# # Default deploy_to directory is /var/www/my_app
# # set :deploy_to, '/var/www/my_app'

# # Default value for :scm is :git
# # set :scm, :git

# # Default value for :format is :pretty
# # set :format, :pretty

# # Default value for :log_level is :debug
# # set :log_level, :debug

# # Default value for :pty is false
# # Default value for :linked_files is []
# # set :linked_files, %w{config/database.yml}

# # Default value for linked_dirs is []
# # set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
# set :deploy_via, :remote_cache
# # Default value for default_env is {}
# # set :default_env, { path: "/opt/ruby/bin:$PATH" }

# # Default value for keep_releases is 5
# # set :keep_releases, 5

# # role :web, "106.185.48.38"                          # Your HTTP server, Apache/etc
# # role :app, "106.185.48.38"                          # This may be the same as your `Web` server
# set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/assets}

# set :linked_files, %w{config/database.yml}
# SSHKit.config.command_map[:rake]  = "bundle exec rake" #8
# SSHKit.config.command_map[:rails] = "bundle exec rails"


# namespace :deploy do

#   desc 'Restart application'
#   task :restart do
#     on roles(:app), in: :sequence, wait: 5 do
#       execute :touch, release_path.join('tmp/restart.txt')
#     end
#     invoke 'delayed_job:restart'
#   end

#   after :finishing, 'deploy:cleanup'
#   after :publishing, 'deploy:restart'
# end
# config valid only for current version of Capistrano
lock '3.3.3'

set :application, 'vtapp'
set :repo_url, 'https://github.com/siddharth28/vtapp.git'

set :sudo, false
set :linked_files, %w{config/database.yml
                      config/secrets.yml}

set :linked_dirs, %w{log
                    tmp/pids
                    tmp/cache
                    tmp/sockets
                    vendor/bundle
                    public/system
                    public/assets}

set :keep_releases, 15

namespace :deploy do
  after :publishing, :restart

  after :restart, :unicorn_restart do
    on roles(:web), in: :parallel do
      within current_path do
        with rails_env: fetch(:rails_env) do
          Rake::Task[:'unicorn:hard_restart'].invoke
        end
      end
    end
  end
end

namespace :unicorn do
  task :hard_restart do
    Rake::Task[:'unicorn:stop'].invoke
    Rake::Task[:'unicorn:start'].invoke
  end

  desc 'start unicorn'
  task :start do
    on roles(:app), in: :parallel do
      within current_path do
        execute :bundle, :exec, "unicorn_rails -c config/unicorn.rb -D -E #{ fetch(:rails_env) }"
      end
    end
  end

  desc 'stop unicorn'
  task :stop do
    on roles(:app), in: :parallel do
      within current_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, :exec, "kill -s QUIT `cat #{shared_path}/tmp/pids/unicorn.pid`"
        end
      end
    end
  end

  desc 'restart unicorn'
  task :restart do
    on roles(:app), in: :parallel do
      within current_path do
        execute "kill -s USR2 `cat #{shared_path}/tmp/pids/unicorn.pid`"
      end
    end
  end
end
