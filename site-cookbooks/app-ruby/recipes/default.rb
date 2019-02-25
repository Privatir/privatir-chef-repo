# site-cookbooks/app-ruby/recipes/default.rb

rbenv_system_install 'privatir'

rbenv_ruby '2.6.1'

rbenv_global '2.6.1'
