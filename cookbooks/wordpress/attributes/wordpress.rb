set_unless[:wordpress][:version]       = "2.9.2"
set_unless[:wordpress][:dir]           = "/srv/wordpress"
set_unless[:wordpress][:db][:name]     = "wordpress"
set_unless[:wordpress][:db][:user]     = "wordpress"
set_unless[:wordpress][:db][:password] = "wordpress"
set_unless[:wordpress][:db][:setup][:user]     = "root"