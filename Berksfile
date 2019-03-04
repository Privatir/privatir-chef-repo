source 'https://api.berkshelf.com'

# Initializing Users & Groups, setting hostname dependencies
cookbook 'users', '~> 5.4.0'
cookbook 'hostname', '~> 0.4.2'
cookbook 'sudo', '~> 5.4.4'

# Postgres
cookbook 'postgresql_lwrp', '~> 1.4.2'

# Ruby Dependencies
cookbook 'ruby_rbenv', '~> 2.1.2'

# Nodejs Dependencies
cookbook 'nodejs', '~> 5.0.0'

# Redis Dependencies
cookbook 'redisio', '~> 3.0.0'

# Nginx Dependencies
cookbook 'nginx', '~> 9.0.0'

# ACME client for generating SSL/TLS certs via Let's Encrypt
cookbook 'acme', '~> 4.0.0'

# Deploy resource, was deprecated in >= Chef 14.0...
# Probably better best practice for this; mimics Capistrano deploy; deploy:migration
cookbook 'deploy_resource', '~> 1.0.2'

# Privatir App Config
cookbook 'app-hostname', path: './site-cookbooks/app-hostname'
cookbook 'app-attributes', path: './site-cookbooks/app-attributes'
cookbook 'app-users', path: './site-cookbooks/app-users'
cookbook 'app-sudo', path: './site-cookbooks/app-sudo'
cookbook 'app-postgresql', path: './site-cookbooks/app-postgresql'
cookbook 'app-deploy', path: './site-cookbooks/app-deploy'
cookbook 'app-redis', path: './site-cookbooks/app-redis'
cookbook 'app-ruby', path: './site-cookbooks/app-ruby'
cookbook 'app-nodejs', path: './site-cookbooks/app-nodejs'
cookbook 'app-nginx', path: './site-cookbooks/app-nginx'
