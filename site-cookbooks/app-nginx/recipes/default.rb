# site-cookbooks/app-nginx/recipes/default.rb

include_recipe 'nginx'

domain_name = node['domain_name']
project_dir = 'privatir.com'

%w[/var/www /var/www/privatir.com /var/www/privatir.com/html].each do |path|
  directory path do
    owner 'root'
    group 'root'
    mode '0755'
    action :create
  end
end

template '/var/www/privatir.com/html/index.html' do
  source 'index.html.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template "#{node['nginx']['dir']}/sites-available/#{domain_name}" do
  source "#{node.environment}.erb"
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    ip: node[:ipaddress],
    domain: domain_name,
    project_dir: node['project']['root']
  )
  notifies :restart, 'service[nginx]', :delayed
end

nginx_site domain_name do
  action :enable
end
