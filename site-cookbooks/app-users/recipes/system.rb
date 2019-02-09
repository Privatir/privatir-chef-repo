users_attributes = [
  node['users']['system']['nginx'],
  node['users']['system']['application']
]

users_attributes.each do |attributes|
  # Create the system group with the name attributes ['group']
  group attributes['group'] do
    append true
    system true
    action :create
  end

  # Create the system user with the name attributes ['name']
  user attributes['name'] do
    system true
    shell '/bin/false' # disallow user to interact with shell
    group attributes['group']
    manage_home attributes['home']
    action :create
  end
end
