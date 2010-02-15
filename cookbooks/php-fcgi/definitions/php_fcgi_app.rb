define :php_fcgi_app do
  include_recipe "php-fcgi"
  include_recipe "passenger_nginx"

  server_name = case params[:server_name]
  when Array
    params[:server_name].join(" ")
  else
    params[:server_name].to_s
  end

  template "#{node[:nginx][:conf_dir]}/sites-available/#{params[:name]}" do
    source "php_fcgi_app.conf.erb"
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

  nginx_site params[:name]
end