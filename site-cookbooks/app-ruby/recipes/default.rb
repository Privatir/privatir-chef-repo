# site-cookbooks/app-ruby/recipes/default.rb

# Install rbenv and makes it avilable to the selected user
version = node['ruby']['default']['version']
user = node['project']['user']
group = node['project']['group']

# Make sure that Vagarant user is on the box for dokken

# Keeps the rbenv install upto date
rbenv_user_install user do
  user user
  group group
  update_rbenv true
end

rbenv_plugin 'ruby-build' do
  git_url 'https://github.com/rbenv/ruby-build.git'
  user user
end

rbenv_ruby version do
  user user
  verbose true
end

rbenv_global version do
  user user
end

rbenv_gem 'bundler' do
  user user
  rbenv_version version
  options '--no-rdoc --no-ri'
end
