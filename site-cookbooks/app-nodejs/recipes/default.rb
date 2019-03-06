# site-cookbooks/app-nodejs/recipes/default.rb

# Installs nodejs w/ the method specified in the app-attributes cookbook
include_recipe 'nodejs'

user = node['project']['user']
root_path = node['project']['root']
shared_path = File.join(root_path, 'shared')
config_path = File.join(shared_path, 'config')
ssh_path = File.join(shared_path, '.ssh')
ssh_key_file = File.join(ssh_path, user)
ssh_wrapper_file = File.join(ssh_path, 'wrap-ssh4git.sh')

# SSH for privatirapi -------------------------------------------------------------------------------------------------
directory ssh_path do
  owner user
  group group
  recursive true
end

# Create private key for git checkout
cookbook_file ssh_key_file do
  source 'key'
  owner user
  group group
  mode 0o600
end

# Wrap ssh connections for deploy user to suppress host checking and credential prompts
file ssh_wrapper_file do
  content "#!/bin/bash\n/usr/bin/env ssh -o \"StrictHostKeyChecking=no\" -i \"#{ssh_key_file}\" $1 $2"
  owner user
  group group
  mode 0o755
end

# Pull frontend code from git
git 'frontend' do
  remote 'origin'
  repository node['project']['repository']['frontend']
  user user
  ssh_wrapper ssh_wrapper_file
  destination '/home/deployer/frontend'
end

npm_package 'install node dependencies' do
  path '/home/deployer/frontend' # The root path to your project, containing a package.json file
  json true
  user 'deployer'
end

execute 'start express server' do
  command "/bin/bash -cl 'npm run build && npm run export'"
  user user
  group group
  cwd '/home/deployer/frontend'
  live_stream
end

execute 'copy export dir' do
  command "/bin/bash -cl 'cp -r out/* #{root_path}/current/public/'"
  cwd '/home/deployer/frontend'
  user user
  group group
  live_stream
end
