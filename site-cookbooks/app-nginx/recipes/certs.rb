# site-cookbooks/app-nginx/recipes/certs.rb

include_recipe 'acme'

# Set up contact information. Note the mailto: notation
node.override['acme']['contact'] = ['mailto:cameron.rison@utexas.edu']
# Real certificates please...
node.override['acme']['endpoint'] = 'https://acme-v01.api.letsencrypt.org'

site = "#{node.chef_environment}.privatir.com"
sans = ["www.#{site}"]

directory '/etc/nginx/ssl' do
  owner 'nginx'
  group 'www-data'
  mode '755'
  action :create
end

# Generate a self-signed if we don't have a cert to prevent bootstrap problems
acme_selfsigned site.to_s do
  crt     "/etc/nginx/ssl/#{site}.crt"
  key     "/etc/nginx/ssl/#{site}.key"
  chain "/etc/nginx/ssl/#{site}.pem"
  owner   'nginx'
  group   'www-data'
  notifies :restart, 'service[nginx]', :immediate
  alt_names sans
end

acme_certificate site.to_s do
  crt "/etc/nginx/ssl/#{site}.crt"
  key "/etc/nginx/ssl/#{site}.key"
  chain "/etc/nginx/ssl/#{site}.pem"
  wwwroot "/var/www/#{node.chef_environment}.privatir.com/current/build"
  owner   'nginx'
  group   'www-data'
  notifies :restart, 'service[nginx]'
  alt_names sans
  only_if { node.chef_environment.to_s.eql? 'production' }
end
