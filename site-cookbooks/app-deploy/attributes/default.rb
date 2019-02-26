# site-cookbooks/app-deploy/attributes/default.rb

default['project']['branch'] = 'master'
default['project']['root'] = File.join('/home', node['project']['user'], node['domain_name'])
