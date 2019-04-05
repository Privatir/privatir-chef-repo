# site-cookbooks/app-nginx/attributes/default.rb

include_attribute 'nginx::source'
include_attribute 'nginx::passenger'

source = node['nginx']['source']
user = node['users']['system']['nginx']

override['nginx']['install_method'] = 'package'
override['nginx']['package_name'] = 'nginx-extras'
override['nginx']['repo_source'] = 'passenger'
override['nginx']['version'] = source['version']
override['nginx']['init_style'] = 'systemd'
override['nginx']['user'] = user['name']
override['nginx']['group'] = user['group']
override['nginx']['source']['use_existing_user'] = true
override['nginx']['passenger']['ruby'] = "/home/#{node['project']['user']}/.rbenv/versions/2.5.1/bin/ruby"
override['nginx']['passenger']['root'] = '/usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini'
override['nginx']['default_site_enabled'] = true

# By default, the Passenger log file is the global Nginx error log file. Set this attribute to write passenger log to another location.
override['nginx']['passenger']['passenger_log_file'] = '/var/log/nginx/passenger/error.log'
