set :main_server,           "ec2-176-34-95-121.eu-west-1.compute.amazonaws.com"

set :user,                  "ubuntu"
set :password,              ""
set :deploy_to,             "/home/ubuntu/deploy/#{application}-#{rails_env}"

set :url,                   "#{main_server}"
set :email,                 "s.frank@vierundsechzig.de" 

server "#{main_server}",    :web, :app, :db, :primary => true

