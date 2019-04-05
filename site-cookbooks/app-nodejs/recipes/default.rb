# site-cookbooks/app-nodejs/recipes/default.rb

# Installs nodejs w/ the method specified in the app-attributes cookbook
include_recipe 'nodejs'

user = node['project']['user']
ssh_path = File.join('/home/' + user, '.ssh')
ssh_key_file = File.join(ssh_path, 'id_ed25519')

# Create private key for git checkout
cookbook_file ssh_key_file do
  source 'id_ed25519'
  owner user
  group group
  mode 0o600
end
