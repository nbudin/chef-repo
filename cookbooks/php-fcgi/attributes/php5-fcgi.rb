set_unless[:php][:fcgi][:user]         = "www-data"
set_unless[:php][:fcgi][:socket]       = "/tmp/php-fcgi.socket"
set_unless[:php][:fcgi][:children]     = 1
set_unless[:php][:fcgi][:max_requests] = 100

unless attribute?("php_apps")
  php_apps({})
end
