# site-cookbooks/app-hostname/recipes/default.rb

hostname "#{node.chef_environment}.privatir.com" # read from host json config -> privatir.com
