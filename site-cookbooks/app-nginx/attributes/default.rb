# site-cookbooks/app-nginx/attributes/default.rb

include_attribute 'nginx::source'

source = node['nginx']['source']
user = node['users']['system']['nginx']

override['nginx']['install_method'] = 'source'
override['nginx']['version'] = source['version']
override['nginx']['source']['prefix'] = "/opt/nginx-#{source['version']}"
override['nginx']['source']['sbin_path'] = "#{source['prefix']}/sbin/nginx"
override['nginx']['binary'] = source['sbin_path']
override['nginx']['init_style'] = 'systemd'
override['nginx']['user'] = user['name']
override['nginx']['group'] = user['group']
override['nginx']['source']['default_configure_flags'] = %W[
  --prefix=#{source['prefix']}
  --conf-path=#{node['nginx']['dir']}/nginx.conf
  --sbin-path=#{source['sbin_path']}
]
override['nginx']['default_site_enabled'] = false
