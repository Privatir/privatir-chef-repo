# site-cookbooks/app-deploy/attributes/default.rb

default['project']['branch'] = 'chef-bootstrapping'
default['project']['root'] = File.join('/home', node['project']['user'], node['domain_name'])
default['project']['user'] = default['users']['system']['application']['name']
default['project']['group'] = default['users']['system']['application']['group']
