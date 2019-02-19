# site-cookbooks/app-redis/recipes/default.rb

include_recipe 'redisio'
include_recipe 'redisio::enable'
