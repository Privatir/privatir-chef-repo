# site-cookbooks/app-nginx/recipes/default.rb

include_recipe 'nginx'
include_recipe '::certs'

nginx_user = node['users']['system']['nginx']['name']
nginx_group = node['users']['system']['nginx']['group']

directory '/var/log/nginx/passenger' do
  owner nginx_user
  group nginx_group
  mode '755'
  action :create
end

directory "/var/www/#{node.chef_environment}.privatir.com" do
  owner 'deployer'
  group 'www-data'
  mode '755'
  action :create
end

file '/var/log/nginx/passenger/error.log' do
  content ''
  owner nginx_user
  group nginx_group
  mode '0644'
end

template "#{node['nginx']['dir']}/sites-available/default" do
  source 'default.nginx.conf.erb'
  owner nginx_user
  group nginx_group
  mode '0644'
end

template "#{node['nginx']['dir']}/sites-available/#{node.chef_environment}.privatir.com" do
  source "#{node.chef_environment}.nginx.conf.erb"
  owner nginx_user
  group nginx_group
  mode '0644'
  variables(
    ip: node[:ipaddress],
    domain: "#{node.chef_environment}.privatir.com",
    project_dir: node['project']['root'],
    environment: node.chef_environment
  )
  notifies :restart, 'service[nginx]', :delayed
end

nginx_site "#{node.chef_environment}.privatir.com" do
  action :enable
end
