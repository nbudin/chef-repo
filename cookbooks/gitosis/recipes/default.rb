#
# Cookbook Name:: gitosis
# Recipe:: default
#
# Copyright 2009, Alexander van Zoest
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

include_recipe 'openssh'
include_recipe 'sudo'
include_recipe 'git'

package "gitosis" do
  action :install
end

git_dir = "/srv/#{node[:gitosis][:user]}"
user node[:gitosis][:user] do
  home git_dir
end

directory git_dir do
  owner node[:gitosis][:user]
  mode "0755"
  action :create
end

execute "initialize gitosis with ssh key" do
  command "echo '#{node[:gitosis][:admin_key]}' | sudo -H -u #{node[:gitosis][:user]} gitosis-init"
  action :run
end

