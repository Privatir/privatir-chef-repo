# site-cookbooks/app-deploy/recipes/default.rb

encrypted_data = Chef::EncryptedDataBagItem.load('configs', node.environment)

config = node['project']

deployer = config['user']
deployer_group = config['group']

root_path = config['root']
home_path = File.join('/', 'home', deployer)
shared_path = File.join(root_path, 'shared')
bundle_path = File.join(shared_path, 'vendor', 'bundle')
config_path = File.join(shared_path, 'config')
ssh_path = File.join(shared_path, '.ssh')

# SSH -------------------------------------------------------------------------------------------------

ssh_key_file = File.join(ssh_path, deployer)
ssh_wrapper_file = File.join(ssh_path, 'wrap-ssh4git.sh')

directory ssh_path do
  owner deployer
  group deployer_group
  recursive true
end

cookbook_file ssh_key_file do
  source 'key'
  owner deployer
  group deployer_group
  mode 0o600
end

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

template File.join(config_path, 'database.yml') do
  source File.join(node.environment, 'database.yml.erb')
  variables(
    environment: node.environment,
    database: encrypted_data['database']['name'],
    user: encrypted_data['database']['user'],
    password: encrypted_data['database']['password']
  )
  sensitive true
  owner deployer
  group deployer_group
  mode 0o644
end

file File.join(config_path, 'application.yml') do
  content Hash[node.environment, encrypted_data['application']].to_yaml
  sensitive true
  owner deployer
  group deployer_group
  mode 0o644
end

# DEPLOYMENT ----------------------------------------------------------------------------------------------------------

timestamped_deploy node['domain_name'] do
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

  # Before you start to run the migration, create tmp and public directories.
  create_dirs_before_symlink %w[tmp public]

  # Map files in a shared directory to their paths in the current release directory.
  symlinks(
    'config/application.yml' => 'config/application.yml',
    'config/database.yml' => 'config/database.yml',
    'config/newrelic.yml' => 'config/newrelic.yml',
    'config/sidekiq.yml' => 'config/sidekiq.yml',
    'log' => 'log',
    'public/system' => 'public/system',
    'public/uploads' => 'public/uploads',
    'public/assets' => 'public/assets',
    'tmp/cache' => 'tmp/cache',
    'tmp/pids' => 'tmp/pids',
    'tmp/sockets' => 'tmp/sockets'
  )

  # Map files in a shared directory to the current release directory.
  symlink_before_migrate(
    'config/application.yml' => 'config/application.yml',
    'config/database.yml' => 'config/database.yml'
  )

  # Run this code before the migration starts
  before_migrate do
    file maintenance_file do
      owner deployer
      group deployer_group
      action :create
    end

    # Install bundler gem
    execute 'install bundler' do
      command "/bin/bash -lc 'source $HOME/.rvm/scripts/rvm && gem install bundler'"
      cwd release_path
      user deployer
      group deployer_group
      environment(
        'HOME' => home_path
      )
    end

    # Install other gems
    execute 'bundle install' do
      command "/bin/bash -lc 'source $HOME/.rvm/scripts/rvm && bundle install --without development test --deployment --path #{bundle_path}'"
      cwd release_path
      user deployer
      group deployer_group
      environment(
        'HOME' => home_path
      )
    end
  end

  migration_command "/bin/bash -lc 'source $HOME/.rvm/scripts/rvm && bundle exec rails db:migrate --trace'"
  migrate true

  # Run the following tasks before app restart commands
  before_restart do
    execute 'db:seed' do
      command "/bin/bash -lc 'source $HOME/.rvm/scripts/rvm && bundle exec rake db:seed'"
      cwd release_path
      user 'root'
      group 'root'
      environment(
        'HOME' => home_path,
        'RAILS_ENV' => node.environment
      )
    end

    execute 'assets:precompile' do
      command "/bin/bash -lc 'source $HOME/.rvm/scripts/rvm && bundle exec rake assets:precompile'"
      cwd release_path
      user 'root'
      group 'root'
      environment(
        'HOME' => home_path,
        'RAILS_ENV' => node.environment
      )
    end
  end

  # Once you've restarted the app, remove the maintenance file
  after_restart do
    file maintenance_file do
      action :delete
    end
  end

  action :deploy
end
