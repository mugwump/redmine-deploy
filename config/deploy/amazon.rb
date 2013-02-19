set :main_server,           "add-your-ec2-server-here"

set :user,                  "ubuntu"
set :password,              ""
set :deploy_to,             "/home/ubuntu/deploy/#{application}-#{rails_env}"

set :url,                   "#{main_server}"
set :email,                 "test@test.com"

server "#{main_server}",    :web, :app, :db, :primary => true

