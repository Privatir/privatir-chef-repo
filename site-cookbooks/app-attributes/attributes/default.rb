# Project -------------------------------------------------------

override['project']['name'] = 'privatir'
override['project']['user'] = 'deployer'
override['project']['group'] = 'sysadmin'
override['project']['repository'] = 'git@github.com:Privatir/privatir-api.git'
default['domain_name'] = node['fqdn']

# Locale ---------------------------------------------------------

override['locale']['lang'] = 'en_US.UTF-8'
override['locale']['lc_all'] = node['locale']['lang']

# Postgresql -----------------------------------------------------

override['postgresql']['enable_pgdg_apt'] = true
override['postgresql']['version'] = '9.6'
override['postgresql']['users'] = [{
  'name' => 'deployer',
  'encrypted_password' => 'md56f297a0fcb4b86fc709fbbdc5c5f79dc',
  'superuser' => true
}, {
  'name' => node['project']['name'],
  'encrypted_password' => 'md56f297a0fcb4b86fc709fbbdc5c5f79dc',
  'superuser' => false # the user of the project's database must have access only to the project database
}]

override['postgresql']['databases'] = [{
  'name' => "#{node['project']['name']}_#{node['chef_environment']}",
  'owner' => node['project']['name']
}]

# Ruby -----------------------------------------------------------
override['ruby']['version'] = ['2.5.1']
override['ruby']['default'] = '2.5.1'

# Nodejs ---------------------------------------------------------
override['nodejs']['version'] = '10.15.1'
override['nodejs']['binary']['checksum'] = 'b7338f2b1588264c9591fef08246d72ceed664eb18f2556692b4679302bbe2a5'

# Nginx -----------------------------------------------------------
override['nginx']['source']['version'] = '1.15.8'
override['nginx']['source']['checksum'] = 'a8bdafbca87eb99813ae4fcac1ad0875bf725ce19eb265d28268c309b2b40787'
