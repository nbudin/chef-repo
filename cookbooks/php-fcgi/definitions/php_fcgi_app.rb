define :php_fcgi_app do
  include_recipe "php-fcgi"
  include_recipe "passenger_nginx"

  nginx_site params[:name] do
    config_template "php_fcgi_app.conf.erb"
    cookbook "php-fcgi" unless params[:cookbook]
    params.each do |k, v|
      send(k, v)
    end
  end
end