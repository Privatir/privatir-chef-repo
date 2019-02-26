# site-cookbooks/app-deploy/recipes/default.rb

encrypted_data = Chef::EncryptedDataBagItem.load('configs', node.environment)

config = node['project']

deployer = config['user']
deployer_group = config['group']

# Canonical rails app directory structure stubs
root_path = config['root']
home_path = File.join('/', 'home', deployer)
shared_path = File.join(root_path, 'shared')
config_path = File.join(shared_path, 'config')
bundle_path = File.join(shared_path, 'vendor', 'bundle')
ssh_path = File.join(shared_path, '.ssh')
ssh_key_file = File.join(ssh_path, deployer)
ssh_wrapper_file = File.join(ssh_path, 'wrap-ssh4git.sh')

# SSH -------------------------------------------------------------------------------------------------
directory ssh_path do
  owner deployer
  group deployer_group
  recursive true
end

# Create private key for git checkout
cookbook_file ssh_key_file do
  source 'key'
  owner deployer
  group deployer_group
  mode 0o600
end

# Wrap ssh connections for deploy user to suppress host checking and credential prompts
file ssh_wrapper_file do
  content "#!/bin/bash\n/usr/bin/env ssh -o \"StrictHostKeyChecking=no\" -i \"#{ssh_key_file}\" $1 $2"
  owner deployer
  group deployer_group
  mode 0o755
end

# DIRECTORIES ---------------------------------------------------------------------------------------------------------
%w[config log public/system public/uploads public/assets repo tmp/cache tmp/pids tmp/sockets].each do |dir|
  directory File.join(shared_path, dir) do
    owner deployer
    group deployer_group
    mode 0o755
    recursive true
  end
end

# DEPLOYMENT ----------------------------------------------------------------------------------------------------------

deploy node['domain_name'] do
  ssh_wrapper ssh_wrapper_file
  repository config['repository']
  branch config['branch']
  repository_cache 'repo'
  deploy_to config['root']
  user deployer
  group deployer_group

  # Set global environments
  environment(
    'HOME' => home_path,
    'RAILS_ENV' => node.environment
  )

  before_restart do
    execute 'Rails setup' do
      command './bin/setup'
      cwd release_path
      live_stream true
      # user deployer
      # group deployer_group
      environment(
        'HOME' => home_path
      )
    end
  end

  action :deploy
end
