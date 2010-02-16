#
# Cookbook Name:: wordpress
# Recipe:: default
#
# Copyright 2010, Nat Budin
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "mysql::client"

package "unzip"

remote_file "/tmp/wordpress.tar.gz" do
  source "http://wordpress.org/wordpress-#{node[:wordpress][:version]}.tar.gz"
  not_if { File.exists? node[:wordpress][:dir] }
end

directory node[:wordpress][:dir] do
  owner node[:php][:fcgi][:user]
  group node[:nginx][:group]
end

execute "tar" do
  cwd node[:wordpress][:dir]
  command "tar --strip-components=1 xfz /tmp/wordpress.tar.gz"
  creates File.join(node[:wordpress][:dir], "index.php")
  user node[:php][:fcgi][:user]
end

node[:wordpress][:db][:host] ||= node[:fqdn]

file "/tmp/wp-init.sql" do
  action :nothing
end

node[:wordpress][:db][:setup][:password] ||= node[:mysql][:server_root_password]
execute "Initialize Wordpress database" do
  command("mysql -h #{node[:wordpress][:db][:host]} "+
      "-u #{node[:wordpress][:db][:setup][:user]} -p#{node[:wordpress][:db][:setup][:password]} "+
      "#{node[:wordpress][:db][:name]} </tmp/wp-init.sql")
  action :nothing
  notifies :delete, resources(:file => "/tmp/wp-init.sql")
end

template "/tmp/wp-init.sql" do
  source "wp-init.sql.erb"
  variables(
    :db => node[:wordpress][:db]
  )
  action :nothing
  notifies :run, resources(:execute => "Initialize Wordpress database")
end

template "#{node[:wordpress][:dir]}/wp-config.php" do
  owner node[:php][:fcgi][:user]
  group node[:nginx][:group]
  mode "0640"
  variables(
    :db => node[:wordpress][:db]
  )
  notifies :create, resources(:template => "/tmp/wp-init.sql")
end

plugins = node[:wordpress][:plugins] || []
plugins_dir = File.join(node[:wordpress][:dir], "wp-content", "plugins")
plugins.each do |plugin|
  dest_dir = File.join(plugins_dir, plugin)
  dest_file = File.join(plugins_dir, "#{plugin}.php")

  remote_file "/tmp/#{plugin}.zip" do
    source "http://wordpress.org/plugin/#{plugin}.zip"
    not_if { File.exists?(dest_dir) || File.exists?(dest_file) }
  end

  execute "Unpack plugin" do
    cwd plugins_dir
    command "unzip /tmp/#{plugin}.zip"
    user node[:php][:fcgi][:user]
    not_if { File.exists?(dest_dir) || File.exists?(dest_file) }
  end
end

themes_dir = File.join(node[:wordpress][:dir], "wp-content", "themes")
if node[:wordpress][:theme]
  dest_dir = File.join(themes_dir, node[:wordpress][:theme][:dir])

  remote_file "/tmp/wp-theme.zip" do
    source node[:wordpress][:theme][:url]
    not_if { File.exists?(dest_dir) }
  end

  execute "Unpack theme" do
    cwd themes_dir
    command "unzip /tmp/wp-theme.zip"
    user node[:php][:fcgi][:user]
    not_if { File.exists?(dest_dir) }
  end
end

node[:wordpress][:server_name] ||= node[:fqdn]
php_fcgi_app "wordpress" do
  server_name node[:wordpress][:server_name]
  dir         node[:wordpress][:dir]
end