# site-cookbooks/app-nginx/recipes/default.rb

include_recipe 'nginx::source'

template "#{node['nginx']['dir']}/sites-available/#{node.domain_name}" do
  source "#{node.environment}.erb"
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    ip: node[:ipaddress],
    domain: node[:domain_name],
    project_dir: node['project']['root']
  )
  notifies :restart, 'service[nginx]', :delayed
end

nginx_site node.domain_name do
  enable true
end
