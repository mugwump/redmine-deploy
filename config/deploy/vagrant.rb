set :main_server,           "192.168.1.10"

set :user,                  "vagrant"
set :password,              "vagrant"
set :deploy_to,             "/home/vagrant/deploy/#{application}-#{rails_env}"

set :url,                   "localhost"
set :email,                 "test@test.de"

set :mysql, :root_pw  => "s00pers3cr3t",
            :database => "redmine",
            :username => "redmine",
            :usr_pw   => "s3cr3t"

server "#{main_server}",    :web, :app, :db, :primary => true

