abort "please set :stage as one of the :chef_attributes in capistrano" unless node[:stage]

# is this package here still needed, when the imagemagick-recipes are already inclued?!
#package "imagemagick"
package "postfix"
package "memcached"

directory node[:deploy_to] do
  owner node[:user]
  group "www-data"
  mode "0755"
  recursive true
end

directory node[:shared_path] do
  owner node[:user]
  group "www-data"
  mode "0755"
  recursive true
end

gem_package "bundler"
