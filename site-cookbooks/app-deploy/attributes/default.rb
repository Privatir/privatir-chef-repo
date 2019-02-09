# site-cookbooks/app-deploy/attributes/default.rb

default['project']['user'] = default['users']['system']['application']['name']
default['project']['group'] = default['users']['system']['application']['group']
default['project']['root'] = File.join('/home', node['project']['user'], node['domain_name'])
