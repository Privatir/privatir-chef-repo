# roles/setup.rb

name 'setup'
description 'Basic setup'

# Run default recipes of these cookbooks one-by-one
run_list 'recipe[app-hostname]',
         'recipe[app-users]',
         'recipe[app-sudo]'
