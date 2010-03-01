nginx_filename = ["nginx", node[:nginx][:version] ].join("-")+".tar.gz"
nginx_src = ["nginx", node[:nginx][:version]].join("-")

gem 'passenger'

package "build-essential"
package "libxslt1.1"
package "libssl-dev"
package "zlib1g-dev"

remote_file "/tmp/#{nginx_filename}" do
  source "http://nginx.org/download/nginx-#{node[:nginx][:version]}.tar.gz"
  not_if { File.exists? node[:nginx][:dir] }
end

execute "tar" do
  cwd "/tmp"
  command "tar xfz #{nginx_filename}"
  creates "/tmp/#{nginx_src}"
  not_if { File.exists? node[:nginx][:dir] }
end

execute "passenger-install-nginx-module" do
  command "/usr/local/bin/passenger-install-nginx-module --auto --nginx-source=/tmp/#{nginx_src} --extra-configure-flags='--with-http_ssl_module' --prefix=#{node[:nginx][:dir]}"
  creates node[:nginx][:dir]
  not_if { File.exists? node[:nginx][:dir] }
end

link node[:nginx][:conf_dir] do
  link_type :symbolic
  to "#{node[:nginx][:dir]}/conf"
end

link node[:nginx][:log_dir] do
  link_type :symbolic
  to "#{node[:nginx][:dir]}/logs"
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode 0755
    owner "root"
    group "root"
  end
end

template "upstart-config" do
  path "/etc/init/nginx.conf"
  source "upstart-config.erb"
  owner "root"
  group "root"
  mode 755
end

upstart_service "nginx" do
  action [ :enable, :start ]
  supports [ :start, :stop, :restart, :reload, :status ]
end

template "nginx.conf" do
  path "#{node[:nginx][:conf_dir]}/nginx.conf"
  source "nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, resources(:service => "nginx")
  variables(
    :passenger_ruby => Gem.ruby,
    :passenger_root => Gem.loaded_specs['passenger'].full_gem_path,
    :passenger_max_pool_size => node[:nginx][:passenger][:max_pool_size],
    :passenger_max_instances_per_app => node[:nginx][:passenger][:max_instances_per_app],
    :passenger_pool_idle_time => node[:nginx][:passenger][:pool_idle_time],
    :rails_app_spawner_idle_time => node[:nginx][:passenger][:app_spawner_idle_time]
  )
end

template "fastcgi_params" do
  path "#{node[:nginx][:conf_dir]}/fastcgi_params"
  source "fastcgi_params.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :reload, resources(:service => "nginx")
end

directory "/etc/nginx/helpers"

# helpers to be included in your vhosts
node[:nginx][:helpers].each do |h|
  template "/etc/nginx/helpers/#{h}.conf" do
    notifies :reload, resources(:service => "nginx")
  end
end

directory "/etc/nginx/conf.d"
directory "/etc/nginx/sites-enabled"
directory "/etc/nginx/sites-available"

# server-wide defaults, automatically loaded
node[:nginx][:extras].each do |ex|
  template "/etc/nginx/conf.d/#{ex}.conf" do
    notifies :reload, resources(:service => "nginx")
  end
end  

