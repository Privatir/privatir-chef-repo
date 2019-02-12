# roles/database.rb

name 'database'
description 'Database setup'

run_list 'recipe[app-postgresql]'
