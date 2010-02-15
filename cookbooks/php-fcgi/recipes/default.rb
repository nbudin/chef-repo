#
# Cookbook Name:: php-fcgi
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

package "php5-cgi"
package "php5-mysql"

template "/etc/default/php5-fcgi" do
  source "defaults.erb"
  variables(
    :user         => node[:php][:fcgi][:user],
    :port         => node[:php][:fcgi][:port],
    :children     => node[:php][:fcgi][:children],
    :max_requests => node[:php][:fcgi][:max_requests]
  )
end

template "/etc/init.d/php5-fastcgi" do
  source "init-script.erb"
end

node[:php_apps].each do |name, properties|
  php_fcgi_app name do
    properties.each do |k, v|
      send(k, v)
    end
  end
end