name 'setup'
description 'Basic setup'

run_list 'recipe[app-hostname]',
         'recipe[app-users]',
         'recipe[app-sudo]'
