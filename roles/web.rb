# roles/web.rb

name 'web'
description 'Web setup'

run_list 'recipe[app-ruby]'
# 'recipe[app-nodejs]',
# 'recipe[app-nginx]',
# 'recipe[app-monit::redis]',
# 'recipe[app-monit::nginx]',
# 'recipe[app-redis]'
