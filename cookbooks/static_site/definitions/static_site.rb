define :static_site do
  nginx_site params[:name] do
    config_template "static_site.conf.erb"
    params.each do |k, v|
      send(k, v)
    end
  end
end