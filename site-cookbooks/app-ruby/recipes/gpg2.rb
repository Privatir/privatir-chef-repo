# site-cookbooks/app-ruby/recipes/gpg2.rb

user = node['project']['user']
group = node['project']['group']

package 'gnupg2' do
  action :install
end

execute 'add gpg2 key' do
  environment ({
    'HOME' => "/home/#{user}",
    'USER' => user
  })

  command 'command curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -'
end

execute 'chown ~/.gnupg' do
  command "chown -R #{user}:#{group} /home/#{user}/.gnupg"
  user 'root'
end
