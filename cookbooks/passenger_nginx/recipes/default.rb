include_recipe "ruby_enterprise_edition"

nginx_filename = ["nginx", node[:nginx][:version], ].join("-")+".tar.gz"

package "libxslt1.1"
package "libopenssl-dev"

remote_file "/tmp/#{nginx_filename}" do
  source nginx_filename
end

execute "passenger-install-nginx-module" do
  command "/usr/local/bin/passenger-install-nginx-module --auto --nginx-source=/tmp/#{nginx_filename} --extra-configure-flags=--with_http_ssl_module --prefix=#{node[:nginx][:dir]}"
  creates node[:nginx][:dir]
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true
end

directory node[:nginx][:log_dir] do
  mode 0755
  owner node[:nginx][:user]
  action :create
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "#{nxscript}.erb"
    mode 0755
    owner "root"
    group "root"
  end
end

template "nginx.conf" do
  path "#{node[:nginx][:dir]}/nginx.conf"
  source "nginx.conf.erb"
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

# server-wide defaults, automatically loaded
node[:nginx][:extras].each do |ex|
  template "/etc/nginx/conf.d/#{ex}.conf" do
    notifies :reload, resources(:service => "nginx")
  end
end  

service "nginx" do
  action [ :enable, :start ]
end
