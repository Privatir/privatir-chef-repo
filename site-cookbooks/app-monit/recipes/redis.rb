# site-cookbooks/app-monit/recipes/redis.rb

include_recipe 'monit'

monit_config 'redis' do
  source 'redis.conf.erb'
end
