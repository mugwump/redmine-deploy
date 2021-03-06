package 'mysql-server'
package 'mysql-client'
package 'libmysqlclient-dev'

execute "set mysql root password" do
  command "mysqladmin -u root password '#{node[:mysql][:root_pw]}'"
  only_if "mysql -u root -e 'show databases' > /dev/null"
end

mysql "create database" do
  password node[:mysql][:root_pw]
  query "CREATE DATABASE IF NOT EXISTS #{node[:mysql][:database]}"
end

mysql "create user" do
  password node[:mysql][:root_pw]
  query "GRANT ALL ON #{node[:mysql][:database]}.* TO '#{node[:mysql][:username]}'@'localhost' IDENTIFIED BY '#{node[:mysql][:usr_pw]}'"
end

template File.join(node[:shared_path], "database.yml") do
  source "database.yml.erb"
  owner node[:user]
  group "www-data"
  mode "0644"
  variables node[:mysql]
end
