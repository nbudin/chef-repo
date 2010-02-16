#
# Cookbook Name:: mysql
# Recipe:: default
#
# Copyright 2008-2009, Opscode, Inc.
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

case node[:platform]
when "debian","ubuntu"

  directory "/var/cache/local/preseeding" do
    owner "root"
    group "root"
    mode 0755
    recursive true
  end

  execute "preseed mysql-server" do
    command "debconf-set-selections /var/cache/local/preseeding/mysql-server.seed"
    action :nothing
  end

  template "/var/cache/local/preseeding/mysql-server.seed" do
    source "mysql-server.seed.erb"
    owner "root"
    group "root"
    mode "0600"
    notifies :run, resources(:execute => "preseed mysql-server"), :immediately
  end
end

package "mysql-server" do
  action :install
end

service "mysql" do
  service_name value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "mysqld"}, "default" => "mysql")

  supports :status => true, :restart => true, :reload => true
  action :enable
end

template value_for_platform([ "centos", "redhat", "suse" ] => {"default" => "/etc/my.cnf"}, "default" => "/etc/mysql/my.cnf") do
  source "my.cnf.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "mysql"), :immediately
end

if (node[:ec2] && ! FileTest.directory?(node[:mysql][:ec2_path]))

  service "mysql" do
    action :stop
  end

  execute "install-mysql" do
    command "mv #{node[:mysql][:datadir]} #{node[:mysql][:ec2_path]}"
    not_if do FileTest.directory?(node[:mysql][:ec2_path]) end
  end

  directory node[:mysql][:ec2_path] do
    owner "mysql"
    group "mysql"
  end

  mount node[:mysql][:datadir] do
    device node[:mysql][:ec2_path]
    fstype "none"
    options "bind,rw"
    action :mount
  end

  service "mysql" do
    action :start
  end

end

begin
  t = resources(:template => "/etc/mysql/grants.sql")
rescue
  Chef::Log.warn("Could not find previously defined grants.sql resource")
  t = template "/etc/mysql/grants.sql" do
    source "grants.sql.erb"
    owner "root"
    group "root"
    mode "0600"
    action :create
  end
end

execute "mysql-install-privileges" do
  # don't pass a -p argument if we didn't set a server root pw
  password_option = node[:mysql][:server_root_password]
  if password_option and password_option.to_s.length >= 1
    password_option = "-p#{password_option}"
  end
  command "/usr/bin/mysql -u root #{password_option} < /etc/mysql/grants.sql"
  action :nothing
  subscribes :run, resources(:template => "/etc/mysql/grants.sql")
end

case node[:platform]
when "debian","ubuntu"
  template "/etc/mysql/debian.cnf" do
    source "debian.cnf.erb"
    mode   "0600"
    owner  "root"
    group  "root"
  end
end
