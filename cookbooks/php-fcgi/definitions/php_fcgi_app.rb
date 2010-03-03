define :php_fcgi_app do
  include_recipe "php-fcgi"
  include_recipe "passenger_nginx"

  params[:config_template] ||= "php_fcgi_app.conf.erb"
  params[:cookbook] ||= "php-fcgi"

  nginx_site params[:name] do
    params.each do |k, v|
      Chef::Log.info("Sending #{k.inspect} -> #{v.inspect} to nginx_site")
      send(k, v)
    end
  end
end