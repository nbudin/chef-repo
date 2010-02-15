set_unless[:php][:fcgi][:user]         = "www-data"
set_unless[:php][:fcgi][:port]         = 9000
set_unless[:php][:fcgi][:children]     = 1
set_unless[:php][:fcgi][:max_requests] = 100