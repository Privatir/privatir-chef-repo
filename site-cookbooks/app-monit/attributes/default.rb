# site-cookbooks/app-monit/attributes/default.rb

default['monit']['poll_period'] = 5 # Interval in seconds to check all Monit services at
default['monit']['port'] = 2812 # Port to listen on for Monit's HTTPD interface
default['monit']['address'] = '0.0.0.0' # Local address to bind to for Monit's HTTPD interface
default['monit']['logfile'] = '/var/log/monit.log' # Path to log messages to
