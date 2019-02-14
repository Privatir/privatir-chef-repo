# site-cookbooks/app-ruby/recipes/default.rb

version = node['ruby']['default']
user = node['project']['user']

# Install rbenv for deploy user
rbenv_user_install user

rbenv_ruby version do
  user user
  verbose true
end

# Set that version as the global Ruby
rbenv_global version do
  user user
end
