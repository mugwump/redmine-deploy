require 'cape'
require "bundler/capistrano"
load "deploy/assets"

# currently, cape does not see the tasks inside engines: the configuration-tasks is therefore mapped manually
Cape do
  # Create Capistrano recipes for all Rake tasks.
  mirror_rake_tasks "redmine_configurator"
end  

# is it the missing RAILS_ENV, that trips up the mysql-commands?!
default_environment['RAILS_ENV'] = "production"

set :stages,              %w(vagrant production amazon)
set :cookbooks_directory, ["config/cookbooks"]

set :use_sudo,            false
set :keep_releases,       10

set :default_run_options, :pty => true
set :ssh_options,         :forward_agent => true

before "bundle:install", "app:update_current_release"
set :bundle_without,  [:development, :test, :postgresql] # explicitly excluding postgres here!!

after "deploy:finalize_update", "app:symlink"
after "deploy:update_code",     "app:remove_rvmrc"
after "deploy",                 "deploy:cleanup"


# currently a self-signed certificate, do not verify
default_environment['GIT_SSL_NO_VERIFY'] = true
set :repository,            "https://hives.alere.com/apiary/git/redmine.git"
set :application,           "redmine"

set :scm,                   :git
set :branch,                "master"

set :stage,                 "#{application}-production"
set :application_directory, "#{application}"


set :deploy_via,            :remote_cache
set :copy_exclude,          [".git", ".gitignore"]

set :rails_env,             "production"
set :ruby_version,          "1.9.3-p194"

set :passenger,             :version => "3.0.12"
set :mysql,                 :root_pw => "methodpark",
                            :database => "redmine",
                            :username => "redmine",
                            :usr_pw => "methodpark"
set :logrotate,             :logs => ["#{deploy_to}/current/log/production.log"]


before "deploy:update_code" do
  run_list = %w{   recipe[application::default]
                   recipe[application::mysql] 
                   recipe[imagemagick] 
                   recipe[imagemagick::devel] 
                   recipe[imagemagick::rmagick] 
                   recipe[sqlite]
                   recipe[graphviz] }
  
  roundsman.run_list run_list
end

after "deploy:create_symlink" do
  roundsman.run_list "recipe[application::apache]"
end



namespace :complete do
  task :setup do
    deploy.setup
    deploy.default
    deploy.migrate
    redmine_configurator.load_default_configuration
  end
end

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# mod_rails/passenger-tasks
# mod_rails is tied to apache, there is no need for an explcit stop/start
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end


namespace :app do
  desc "symbolic link to the shared assets"


  task :symlink, :roles => [:app] do
      # TODO get the dataabase.yml out of version-control and fetch it from somewhere else
      # run "ln -sf #{shared_path}/database.yml #{release_path}/config/database.yml"
      # TODO link the paths to the uploaded files, to make sure they are preserved during deployments
      #run "ln -sf #{shared_path}/files #{release_path}/public/files"
  end

  desc "update the release path, since it's using the previous one"
  task :update_current_release do
    set :current_release, release_path
  end

  desc "remove rvmrc"
  task :remove_rvmrc, :roles => [:app] do
    run "rm #{release_path}/.rvmrc" if file_exists? "#{release_path}/.rvmrc"
  end
end

def file_exists?(path)
  "true" ==  capture("if [ -e #{path} ]; then echo 'true'; fi").strip
end


###### --- custom tasks ------ 
task :echo_env do
  run "env"
end

desc "tail production log files" 
task :tail_logs, :roles => :app do
  run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
    trap("INT") { puts 'Interupted'; exit 0; } 
    puts  # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}" 
    break if stream == :err
  end
end

namespace :redmine_configurator do 
  
  desc "loads the default-configuration for redmine"
  task :load_default_configuration do  
    run("cd #{deploy_to}/current; /usr/bin/env rake redmine_configurator:load_default_configuration RAILS_ENV=#{rails_env}")  
  end
  
end
