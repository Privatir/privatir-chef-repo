# Project -------------------------------------------------------

override['project']['name'] = 'privatir'
override['project']['user'] = 'deployer'
override['project']['group'] = 'sysadmin'
override['project']['repository'] = 'git@github.com:Privatir/privatir-api.git'

# Locale ---------------------------------------------------------

override['locale']['lang'] = 'en_US.UTF-8'
override['locale']['lc_all'] = node['locale']['lang']

# Postgresql -----------------------------------------------------

override['postgresql']['enable_pgdg_apt'] = true
override['postgresql']['version'] = '9.6'
override['postgresql']['users'] = [{
  'name' => 'deployer',
  'encrypted_password' => 'a6e5313fbc0d1d1084075a06b0e85a3e',
  'superuser' => true
}, {
  'name' => node['project']['name'],
  'encrypted_password' => 'a6e5313fbc0d1d1084075a06b0e85a3e',
  'superuser' => false # the user of the project's database must have access only to the project database
}]

override['postgresql']['databases'] = [{
  'name' => "#{node['project']['name']}_#{node['chef_environment']}",
  'owner' => node['project']['name']
}]

# Ruby -----------------------------------------------------------
override['ruby']['versions'] = ['2.6.1']
override['ruby']['default'] = '2.6.1'

# Nodejs ---------------------------------------------------------
override['nodejs']['version'] = '9.3.0'
override['nodejs']['binary']['checksum'] = 'b7338f2b1588264c9591fef08246d72ceed664eb18f2556692b4679302bbe2a5'

# Nginx -----------------------------------------------------------
override['nginx']['source']['version'] = '1.13.7'
override['nginx']['source']['checksum'] = 'beb732bc7da80948c43fd0bf94940a21a21b1c1ddfba0bd99a4b88e026220f5c'

# Monit -----------------------------------------------------------
monit_configs = Chef::EncryptedDataBagItem.load('configs', 'dev')['monit']
override['monit']['username'] = monit_configs['username']
override['monit']['password'] = monit_configs['password']
