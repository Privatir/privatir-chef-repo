# site-cookbooks/app-deploy/recipes/default.rb

config = node['project']

user = config['user']
group = config['group']

# Canonical rails app directory structure stubs
root_path = config['root']
home_path = File.join('/', 'home', user)

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

# RAILS ENV CONFIGURATION VIA FIGARO
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
  repository config['repository']['api']
  branch config['branch']
  repository_cache 'repo'
  deploy_to config['root']
  user user
  group group

  # SET GLOBAL ENVIRONMENTS
  environment(
    'HOME' => home_path,
    'RAILS_ENV' => node.chef_environment
  )

  # BEFORE YOU START TO RUN THE MIGRATION, CREATE TMP AND PUBLIC DIRECTORIES.
  create_dirs_before_symlink %w[tmp public]

  # MAP FILES IN A SHARED DIRECTORY TO THEIR PATHS IN THE CURRENT RELEASE DIRECTORY.
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

  # ADD SYMLINKS TO THESE CONFIGS THAT SHOULD BE FRESH PER DEPLOY
  symlink_before_migrate(
    'config/application.yml' => 'config/application.yml',
    'config/database.yml' => 'config/database.yml',
    'config/credentials.yml.enc' => 'config/credentials.yml.enc'
  )

  # TASK PERFORMED BEFORE DATABASE MIGRATIONS
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

    # DB IS ALREADY CREATED W/ PROVISIONED USER; LOAD DB SCHEMA, MIGRATE, SEED
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

  # TASKS BEFORE RESTARTING NGINX + PASSENGER
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

  # RESTART NGINX, WHICH RESTARTS PASSENGER
  notifies :restart, 'service[nginx]', :delayed
end
