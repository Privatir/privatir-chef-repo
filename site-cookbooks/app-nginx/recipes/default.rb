# site-cookbooks/app-nginx/recipes/default.rb

include_recipe 'nginx'
include_recipe '::certs'

directory '/var/log/nginx/passenger' do
  owner 'root'
  group 'root'
  mode '755'
  action :create
end

file '/var/log/nginx/passenger/error.log' do
  content ''
  owner 'root'
  group 'root'
  mode '0644'
end

template "#{node['nginx']['dir']}/sites-available/#{node['fqdn']}" do
  source "#{node.chef_environment}.nginx.conf.erb"
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    ip: node[:ipaddress],
    domain: node['fqdn'],
    project_dir: node['project']['root'],
    environment: node.chef_environment
  )
  notifies :restart, 'service[nginx]', :delayed
end

nginx_site node['fqdn'] do
  action :enable
end
