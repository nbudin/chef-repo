define :php_fcgi_app do
  include_recipe "php-fcgi"
  include_recipe "passenger_nginx"

  params[:config_template] ||= "php_fcgi_app.conf.erb"
  params[:cookbook] ||= "php-fcgi"

  pass_params = params  
  nginx_site pass_params.delete(:name) do
    pass_params.each do |k, v|
      send(k, v)
    end
  end
end