# site-cookbooks/app-postgresql/recipes/default.rb

include_recipe 'postgresql_lwrp::apt_official_repository'
include_recipe 'postgresql_lwrp'

locale = node['locale']['lang']
version = node['postgresql']['defaults']['server']['version']
users = node['postgresql']['users']
databases = node['postgresql']['databases']

# Basic  settings for authentication
general_hba = [
  { type: 'host', database: 'all', user: 'all', address: '::1/128', method: 'md5' },
  { type: 'host', database: 'all', user: 'all', address: '127.0.0.1/32', method: 'md5' },
  { type: 'local', database: 'all', user: 'postgres', address: '', method: 'peer' }
]

# Authentication settings for the user
users_hba = users.map do |attributes|
  {
    type: 'local',
    database: attributes['name'],
    user: attributes['name'],
    address: '',
    method: attributes['superuser'] ? 'peer' : 'md5'
  }
end

# Authentication settings for groups
databases_hba = databases.map do |attributes|
  {
    type: 'local',
    database: attributes['name'],
    user: attributes['owner'],
    address: '',
    method: 'md5'
  }
end

# LWRP to create main db cluster w/ prescribed config
postgresql 'main' do
  cluster_version(version)
  cluster_create_options(locale: locale)
  configuration(max_connections: 300)
  hba_configuration([*general_hba, *users_hba, *databases_hba])
end

users.each do |attributes|
  postgresql_user attributes['name'] do
    in_cluster 'main'
    in_version version
    superuser attributes['superuser']
    encrypted_password attributes['encrypted_password']
  end
end

databases.each do |attributes|
  postgresql_database attributes['name'] do
    in_cluster 'main'
    in_version version
    owner attributes['owner']
  end
end
