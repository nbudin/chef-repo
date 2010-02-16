set_unless[:wordpress][:version]       = "2.9.2"
set_unless[:wordpress][:dir]           = "/srv/wordpress"
set_unless[:wordpress][:db][:name]     = "wordpress"
set_unless[:wordpress][:db][:user]     = "wordpress"
set_unless[:wordpress][:db][:password] = "wordpress"
set_unless[:wordpress][:db][:host]     = node[:fqdn]
set_unless[:wordpress][:server_name]   = node[:fqdn]

set_unless[:wordpress][:db][:setup][:user]     = "root"
set_unless[:wordpress][:db][:setup][:password] = node[:mysql][:server_root_password]