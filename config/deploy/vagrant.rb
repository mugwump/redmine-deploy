set :main_server,           "192.168.1.10"

set :user,                  "vagrant"
set :password,              "vagrant"
set :deploy_to,             "/home/vagrant/deploy/#{application}-#{rails_env}"

set :url,                   "localhost"
set :email,                 "s.frank@vierundsechzig.de" 

server "#{main_server}",    :web, :app, :db, :primary => true

