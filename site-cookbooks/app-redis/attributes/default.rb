# site-cookbooks/app-redis/attributes/default.rb

default['redisio']['servers'] = [{
  'port' => '6379', 'name' => 'master', 'user' => 'redis', 'group' => 'redis',
  'databases' => '2'
}]
