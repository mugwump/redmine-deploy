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
set :templates_directory, ["templates"]

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
                            :usr_pw => "methodpark",
                            :host => "localhost"
                            
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
  desc <<-EOD
     Creates the upload folders unless they exist
     and sets the proper upload permissions.
   EOD
   task :setup, :except => { :no_release => true } do
     upload_dir = File.join(shared_path, "files")
     run "#{try_sudo} mkdir -p #{upload_dir} && #{try_sudo} chmod g+w #{upload_dir}"   
   end
   
  desc "symbolic link to the shared assets"
    task :symlink, :roles => [:app] do
      run "rm -rf #{release_path}/files"
      run "ln -nsf #{shared_path}/files  #{release_path}/files"
    end

  desc "update the release path, since it's using the previous one"
  task :update_current_release do
    set :current_release, release_path
  end

  desc "remove rvmrc"
  task :remove_rvmrc, :roles => [:app] do
    run "rm #{release_path}/.rvmrc" if file_exists? "#{release_path}/.rvmrc"
  end
  
  after "deploy:setup", "app:setup"
  after "deploy:finalize_update", "app:symlink"
  
end



namespace :db do

    desc <<-DESC
      Creates the database.yml configuration file in shared path.

      By default, this task uses a template unless a template
      called database.yml.erb is found either is :templates_directory
      or /config/deploy folders. The default template matches
      the template for config/database.yml file shipped with Rails.

      When this recipe is loaded, db:setup is automatically configured
      to be invoked after deploy:setup. You can skip this task setting
      the variable :skip_db_setup to true. This is especially useful
      if you are using this recipe in combination with
      capistrano-ext/multistaging to avoid multiple db:setup calls
      when running deploy:setup for all stages one by one.
    DESC
    task :setup, :except => { :no_release => true } do
      
      default_template = <<-EOF
      base: &base
        adapter: sqlite3
        timeout: 5000
      development:
        database: #{shared_path}/db/development.sqlite3
        <<: *base
      test:
        database: #{shared_path}/db/test.sqlite3
        <<: *base
      production:
        database: #{shared_path}/db/production.sqlite3
        <<: *base
      EOF
      
      location = fetch(:templates_directory).join("") + '/database.yml.erb'
      puts "location --> #{location}"
      template = File.file?(location) ? File.read(location) : default_template

      
      
      config = ERB.new(template)
      
      run "mkdir -p #{shared_path}/db"
      run "mkdir -p #{shared_path}/config"
        

      put config.result(binding), "#{shared_path}/config/database.yml"
    end
    
    desc <<-DESC
      [internal] Updates the symlink for database.yml file to the just deployed release.
    DESC
    task :symlink, :except => { :no_release => true } do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end

    after "deploy:setup",           "db:setup"   unless fetch(:skip_db_setup, false)
    after "deploy:finalize_update", "db:symlink"

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
