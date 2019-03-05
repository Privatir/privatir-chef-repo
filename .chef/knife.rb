node_name 'iillmaticc'
current_dir = ::File.dirname(__FILE__)
log_level                :info
log_location             $stdout
node_name                'iillmaticc'
client_key               ::File.join(current_dir, 'iillmaticc.pem')
validation_client_name   'default-validator'
validation_key           ::File.join(current_dir, 'default-validator.pem')
chef_server_url          'https://ec2-35-172-129-125.compute-1.amazonaws.com/organizations/default'
cookbook_path            [::File.join(current_dir, '../site-cookbooks')]
knife[:editor] = 'vim'
