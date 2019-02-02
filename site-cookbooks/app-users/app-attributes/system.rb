# site-cookbooks/app-users/attributes/system.rb

default['users']['system']['application']['name'] = node['project']['name']
default['users']['system']['application']['group'] = 'www-data'
default['users']['system']['application']['home'] = true