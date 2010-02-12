define :rails_app, :deploy => true do
  include_recipe "rails_app"
  include_recipe "git"

  params[:environment]     ||= "production"
  params[:migrate_command] ||= "rake #{railsapp[:environment]} db:migrate"
  params[:migrate]         ||= false

  params[:db] ||= {}
  params[:db].each do |env_name, db_params|
    case db_params[:type]
    when "sqlite"
      include_recipe "sqlite"
      gem_package "sqlite3-ruby" 
      file "#{root_dir}/shared/sqlite/production.sqlite3" do
        owner "www-data"
        group "www-data"
        mode "0664"
      end
    when "mysql"
      include_recipe "mysql::client"
    end
  end  

  include_recipe "rails"
  include_recipe "passenger_nginx"
  
  %w{config log pids sqlite system}.each do |dir|
    directory "/srv/#{params[:name]}/shared/#{dir}" do
      recursive true
      owner "www-data"
      group "www-data"
      mode "0775"
    end
  end
  
  root_dir = "/srv/#{params[:name]}"
  server_name = case params[:server_name]
  when Array
    params[:server_name].join(" ")
  else
    params[:server_name].to_s
  end

  template "#{root_dir}/shared/config/database.yml" do
    source "database.yml.erb"
    owner "www-data"
    group "www-data"
    variables :params => params[:db]
    mode "0664"
  end

  deploy root_dir do
    scm = params[:scm_provider]
    case (scm && scm.to_sym)
    when :subversion, :svn
      scm_provider Chef::Provider::Subversion
    else
      scm_provider Chef::Provider::Git
      enable_submodules true
    end
    repo params[:repo]
    branch params[:branch]
    user "www-data"
    migrate params[:migrate]
    migration_command params[:migrate_command]
    environment params[:environment]
    shallow_clone true
    revision params[:revision]
    action (params[:action] || :deploy).to_sym
    restart_command "touch tmp/restart.txt"
  end
    
  template "#{node[:nginx][:conf_dir]}/sites-available/#{params[:name]}" do
    source "rails_app.conf.erb"
    owner "root"
    group "root"
    mode 0644
    if params[:cookbook]
      cookbook params[:cookbook]
    end
    variables(
      :root_dir => root_dir,
      :server_name => server_name,
      :params => params
    )
    if File.exists?("#{node[:nginx][:conf_dir]}/sites-enabled/#{params[:name]}.conf")
      notifies :reload, resources(:service => "nginx"), :delayed
    end
  end
  
  nginx_site params[:name]

  execute "install_gems" do
    command "rake #{params[:environment]} gems:install"
    cwd File.join(root_dir, "current")
  end
end
