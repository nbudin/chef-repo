#
# Cookbook Name:: scout
# Recipe:: default
#
# Copyright 2010, Example Com
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

gem_package "scout" do
  source "http://gems.rubyforge.org"
end

gem "scout"

cron "scout" do
  minute "*/30"
  user "www-data"
  command "#{Gem.loaded_specs['scout'].full_gem_path}/bin/scout #{node[:scout][:client_key]}"
end
