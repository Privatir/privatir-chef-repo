# site-cookbooks/app-deploy/recipes/default.rb

encrypted_data = search(:configs, 'id:dev')

config = node['project']

user = config['user']
group = config['group']

# Canonical rails app directory structure stubs
root_path = config['root']
home_path = File.join('/', 'home', user)

shared_path = File.join(root_path, 'shared')
config_path = File.join(shared_path, 'config')
bundle_path = File.join(shared_path, 'vendor', 'bundle')
ssh_path = File.join(shared_path, '.ssh')
ssh_key_file = File.join(ssh_path, user)
ssh_wrapper_file = File.join(ssh_path, 'wrap-ssh4git.sh')

# SSH -------------------------------------------------------------------------------------------------
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

# DIRECTORIES ---------------------------------------------------------------------------------------------------------
%w[config log public/system public/uploads public/assets repo tmp/cache tmp/pids tmp/sockets].each do |dir|
  directory File.join(shared_path, dir) do
    owner user
    group group
    mode 0o755
    recursive true
  end
end

# DATABASE YML CONSTRUCTION
template File.join(config_path, 'database.yml') do
  source File.join(node.chef_environment, 'database.yml.erb')
  variables(
    environment: node.chef_environment,
    database: 'privatir_development',
    user: 'privatir',
    password: 'privatir'
  )
  sensitive true
  owner user
  group group
  mode 0o644
end

# rails env configuration via figaro
template File.join(config_path, 'application.yml') do
  source File.join(node.chef_environment, 'application.yml.erb')
  variables(
    environment: node.chef_environment,
    user: 'privatir'
  )
  sensitive true
  owner user
  group group
  mode 0o644
end

# DEPLOYMENT ----------------------------------------------------------------------------------------------------------

deploy node['domain_name'] do
  ssh_wrapper ssh_wrapper_file
  repository config['repository']
  branch config['branch']
  repository_cache 'repo'
  deploy_to config['root']
  user user
  group group

  # Set global environments
  environment(
    'HOME' => home_path,
    'RAILS_ENV' => node.chef_environment
  )

  # Before you start to run the migration, create tmp and public directories.
  create_dirs_before_symlink %w[tmp public]

  # Map files in a shared directory to their paths in the current release directory.
  symlinks(
    'config/database.yml' => 'config/database.yml',
    'config/application.yml' => 'config/application.yml',
    'log' => 'log',
    'public/system' => 'public/system',
    'public/uploads' => 'public/uploads',
    'public/assets' => 'public/assets',
    'tmp/cache' => 'tmp/cache',
    'tmp/pids' => 'tmp/pids',
    'tmp/sockets' => 'tmp/sockets'
  )

  symlink_before_migrate(
    'config/application.yml' => 'config/application.yml',
    'config/database.yml' => 'config/database.yml',
    'config/credentials.yml.enc' => 'config/credentials.yml.enc'
  )

  before_migrate do
    # Install bundler gem
    execute 'install bundles' do
      command "/bin/bash -cl 'bundle install'"
      cwd release_path
      user user
      group group
      environment(
        'HOME' => home_path,
        'RAILS_ENV' => node.chef_environment
      )
      live_stream true
    end

    # DB is already created w/ provisioned user; load db schema, migrate, seed
    execute 'load schema' do
      command "/bin/bash -cl 'bundle exec rake db:schema:load'"
      cwd release_path
      user user
      group group
      environment(
        'HOME' => home_path,
        'RAILS_ENV' => node.chef_environment
      )
      live_stream true
    end
  end

  migration_command "/bin/bash -cl 'bundle exec rails db:migrate'"
  migrate true

  before_restart do
    execute 'seed database' do
      command "/bin/bash -cl 'bundle exec rake db:seed'"
      cwd release_path
      user user
      group group
      environment(
        'RAILS_ENV' => node.chef_environment,
        'HOME' => home_path
      )
      live_stream true
    end
  end

  action :deploy
  notifies :restart, 'service[nginx]', :delayed
end
