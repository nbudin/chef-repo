define :static_site do
  params[:config_template] ||= "static_site.conf.erb"
  params[:cookbook] ||= "static_site"

  pass_params = params
  nginx_site pass_params.delete(:name) do
    pass_params.each do |k, v|
      send(k, v)
    end
  end
end