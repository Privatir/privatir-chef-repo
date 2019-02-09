# site-cookbooks/app-users/recipes/regular.rb

# Creates the sysadmin group and users defined in the users databag.
users_manage 'sysadmin' do
  group_id 2300
  action :create
end
