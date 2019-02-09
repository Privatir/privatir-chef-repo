# site-cookbooks/app-ruby/recipes/setup.rb

user = node['project']['user']
attributes = node['ruby']

# Install the required versions of Ruby
chef_rvm 'install rubies' do
  rubies attributes['versions']
  rvmrc(rvm_autoupdate_flag: 1)
  user user
end

# Set Ruby version by default
chef_rvm_ruby 'set default ruby version' do
  version attributes['default']
  default true
  user user
end
