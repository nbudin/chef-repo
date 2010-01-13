define :nginx_site, :enable => true do
  include_recipe "passenger_nginx"

  if params[:config_path]
    link "#{node[:nginx][:dir]}/sites-available/#{params[:name]}" do
      to params[:config_path]
      only_if { File.exists?(params[:config_path]) }
    end
  end

  if params[:enable]
    link "#{node[:nginx][:dir]}/sites-enabled/#{params[:name]}" do
      to "#{node[:nginx][:dir]}/sites-available/#{params[:name]}"
      notifies :restart, resources(:service => "nginx")
      only_if { File.exists?("#{node[:nginx][:dir]}/sites-available/#{params[:name]}") }
      not_if do File.symlink?("#{node[:nginx][:dir]}/sites-enabled/#{params[:name]}") end
    end
  else
    link "#{node[:nginx][:dir]}/sites-enabled/#{params[:name]}" do
      action :delete
      notifies :restart, resources(:service => "nginx")
      only_if do File.symlink?("#{node[:nginx][:dir]}/sites-enabled/#{params[:name]}") end
    end
  end
end
