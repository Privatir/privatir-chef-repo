# site-cookbooks/app-ruby/recipes/default.rb

rbenv_system_install 'privatir'

rbenv_ruby node['ruby']['version']

rbenv_global node['ruby']['version']
