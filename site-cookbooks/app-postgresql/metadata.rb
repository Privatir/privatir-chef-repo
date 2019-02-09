# site-cookbooks/app-postgresql/metadata.rb

name    'app-postgresql'
version '0.1.0'

depends 'app-attributes'
depends 'apt'
depends 'postgresql_lwrp'
depends 'locale'