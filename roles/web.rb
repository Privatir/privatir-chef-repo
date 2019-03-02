# roles/web.rb

name 'web'
description 'Web setup'

run_list 'recipe[app-ruby]', 'recipe[app-nginx]', 'recipe[app-deploy]', 'recipe[app-nodejs]'
