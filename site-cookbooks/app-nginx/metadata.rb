# site-cookbooks/app-nginx/metadata.rb

name    'app-nginx'
version '0.1.0'

# depends 'app-deploy'
depends 'app-attributes'
depends 'app-deploy'
depends 'nginx'
