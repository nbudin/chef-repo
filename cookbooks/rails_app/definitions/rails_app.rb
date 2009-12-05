define :rails_app, :deploy => true do
  include_recipe "rails_app"
  include_recipe "git"
  
  case params[:db][:type]
  when "sqlite"
    include_recipe "sqlite"
    gem_package "sqlite3-ruby" 
  when "mysql"
    include_recipe "mysql::client"
  end
  include_recipe "rails"
  include_recipe "passenger_nginx"
  
  %w{config log pids sqlite system}.each do |dir|
    directory "/srv/#{params[:app_name]}/shared/#{dir}" do
      recursive true
      owner "www-data"
      group "www-data"
      mode "0775"
    end
  end

  database_server = params[:db][:server] || "localhost"
  #database_server = search(:node, "database_master:true").map {|n| n['fqdn']}.first

  template "/srv/#{params[:app_name]}/shared/config/database.yml" do
    source "database.yml.erb"
    owner "www-data"
    group "www-data"
    variables :params => params
    mode "0664"
  end

  if params[:db][:type] =~ /sqlite/
    file "/srv/#{params[:app_name]}/shared/sqlite/production.sqlite3" do
      owner "www-data"
      group "www-data"
      mode "0664"
    end
  end

  deploy "/srv/#{params[:app_name]}" do
    repo "git://github.com/radiant/radiant.git"
    branch params[:branch]
    user "www-data"
    enable_submodules false
    migrate params[:migrate]
    migration_command params[:migrate_command]
    environment params[:environment]
    shallow_clone true
    revision params[:revision]
    action params[:action].to_sym
    restart_command "touch tmp/restart.txt"
  end

  web_app "#{params[:app_name]}" do
    docroot "/srv/#{params[:app_name]}/current/public"
    template "#{params[:app_name]}.conf.erb"
    server_name "#{params[:app_name]}.#{node[:domain]}"
    server_aliases [ "#{params[:app_name]}", node[:hostname] ]
    rails_env "production"
  end
end