define :nginx_site, :enable => true do
  include_recipe "passenger_nginx"

  params[:dir] ||= "/srv/#{params[:name]}"

  directory params[:dir] do
    owner node[:nginx][:user]
    group node[:nginx][:group]
    mode 0755
  end

  params[:config_template] ||= "nginx_site.conf.erb"

  template "#{node[:nginx][:conf_dir]}/sites-available/#{params[:name]}" do
    source params[:config_template]
    owner "root"
    group "root"
    mode 0644
    if params[:cookbook]
      cookbook params[:cookbook]
    end
    variables(
      :root_dir => params[:dir],
      :server_name => server_name,
      :params => params
    )
    if File.exists?("#{node[:nginx][:conf_dir]}/sites-enabled/#{params[:name]}.conf")
      notifies :reload, resources(:service => "nginx"), :delayed
    end
  end

  if params[:enable]
    execute "nxensite #{params[:name]}" do
      command "/usr/sbin/nxensite #{params[:name]}"
      notifies :restart, resources(:service => "nginx")
      only_if { File.exists?("#{node[:nginx][:conf_dir]}/sites-available/#{params[:name]}") }
      not_if do File.symlink?("#{node[:nginx][:conf_dir]}/sites-enabled/#{params[:name]}") end
    end
  else
    execute "nxdissite #{params[:name]}" do
      command "/usr/sbin/nxdissite #{params[:name]}"
      notifies :restart, resources(:service => "nginx")
      only_if do File.symlink?("#{node[:nginx][:conf_dir]}/sites-enabled/#{params[:name]}") end
    end
  end
end
