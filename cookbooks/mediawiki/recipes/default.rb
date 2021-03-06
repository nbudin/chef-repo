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

node[:mediawiki_instances].each do |name, properties|
  Chef::Log.info("Deploying MediaWiki instance #{name}")
  mediawiki name do
    properties.each do |k, v|
      next if k.to_s == "name"
      send(k, v)
    end
  end
end