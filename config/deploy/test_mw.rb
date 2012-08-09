set :main_server,           "176.221.43.225"

set :user,                  "root"
set :password,              ""
set :deploy_to,             "/home/ubuntu/deploy/#{application}-#{rails_env}"

set :url,                   "#{main_server}/redmine"
set :email,                 "michael@woecherl.de" 

server "#{main_server}",    :web, :app, :db, :primary => true

