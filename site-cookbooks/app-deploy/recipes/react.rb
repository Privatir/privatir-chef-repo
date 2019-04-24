# Need to npm install the node dependencies from the Capistrano deploy
# location ~> /var/www/*.privatir.com/current
execute 'npm install' do
  command 'sudo npm install'
  cwd '/var/www/dev.privatir.com/current'
  user 'deployer'
  group 'deployer'
  live_stream true
end

# Now need to run npm build script to produce build/ artifacts

execute 'npm run build' do
  command 'sudo npm run build'
  user 'deployer'
  group 'deployer'
  live_stream true
  cwd '/var/www/dev.privatir.com/current'
end
