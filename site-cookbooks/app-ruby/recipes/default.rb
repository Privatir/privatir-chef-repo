# site-cookbooks/app-ruby/recipes/default.rb

rbenv_system_install 'privatir'

# This attribute is being overriden in app-attributes
rbenv_ruby node['ruby']['version']

# Sets the same as what's defined above
rbenv_global node['ruby']['version']
