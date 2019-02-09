# site-cookbooks/app-postgresql/attributes/default.rb

default['postgresql']['client']['version'] = node['postgresql']['version']
default['postgresql']['defaults']['server']['version'] = node['postgresql']['version']
override['postgresql']['defaults']['server']['hba_configuration'] = []
