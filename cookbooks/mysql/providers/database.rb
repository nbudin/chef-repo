include Opscode::Mysql::Database

action :create do
  Chef::Log.info "mysql_database: creating database"

  root_db.create_db(new_resource.name)
  root_db.query("grant all on #{new_resource.name}.* to '#{new_resource.username}'@'#{node[:fqdn]}' identified by '#{new_resource.password}'")
end

action :drop do
  Chef::Log.info "mysql_database: dropping database"

  root_db.drop_db(new_resource.name)
end

action :flush_tables_with_read_lock do
  Chef::Log.info "mysql_database: flushing tables with read lock"
  db.query "flush tables with read lock"
  new_resource.updated = true
end

action :unflush_tables do
  Chef::Log.info "mysql_database: unlocking tables"
  db.query "unlock tables"
  new_resource.updated = true
end
