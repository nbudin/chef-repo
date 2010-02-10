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

user "gitosis"

execute "initialize gitosis with ssh key" do
  case node[:platform]
  when "debian", "ubuntu"
    gitosis_user = "gitosis"
  end
  command "echo '#{node[:gitosis][:admin_key]}' | sudo -H -u #{gitosis_user} gitosis-init"
  action :run
end

