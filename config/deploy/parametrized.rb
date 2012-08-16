# this stage gets its configuration parameters from the environment.
# they are placed there by e.g. Jenkins

set :main_server,           ENV['REDMINE_DEPLOY_MACHINE']

set :user,                  ENV['REDMINE_DEPLOY_USER']
set :password,              ""
set :deploy_to,             ENV['REDMINE_DEPLOY_PATH'] + "/#{application}-#{rails_env}"

set :url,                   main_server + ENV['REDMINE_DEPLOY_REDMINE_URI']
set :email,                 ENV['REDMINE_DEPLOY_EMAIL']

server "#{main_server}",    :web, :app, :db, :primary => true

