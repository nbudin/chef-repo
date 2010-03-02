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

directory node[:mediawiki][:dir] do
  owner node[:php][:fcgi][:user]
  group node[:nginx][:group]
end

execute "Unpack Mediawiki" do
  cwd node[:mediawiki][:dir]
  command "tar x --strip-components=1 -zf /tmp/mediawiki.tar.gz"
  user node[:php][:fcgi][:user]
  action :nothing
end

version_split = node[:mediawiki][:version].split(/\./)
minor_version = "#{version_split[0]}.#{version_split[1]}"
url = "http://download.wikimedia.org/mediawiki/#{minor_version}/mediawiki-#{node[:mediawiki][:version]}.tar.gz"
Chef::Log.info "Will get MediaWiki from #{url}"

remote_file "/tmp/mediawiki.tar.gz" do  
  source url
  owner node[:php][:fcgi][:user]
  not_if { File.exists? File.join(node[:mediawiki][:dir], "index.php") }
  notifies :run, resources(:execute => "Unpack Mediawiki"), :immediately
end

node[:mediawiki][:db][:host] ||= node[:fqdn]

mysql_database node[:mediawiki][:db][:name] do
  action :create

  host node[:mediawiki][:db][:host]
  username node[:mediawiki][:db][:user]
  password node[:mediawiki][:db][:password]
end

node[:mediawiki][:server_name] ||= node[:fqdn]
php_fcgi_app "mediawiki" do
  server_name node[:mediawiki][:server_name]
  dir         node[:mediawiki][:dir]
  cookbook    "mediawiki"
end