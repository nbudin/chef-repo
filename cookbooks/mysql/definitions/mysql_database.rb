define :mysql_database, :action => :create do

  case params[:action].to_sym
  when :create
    params[:host] ||= "localhost"
    params[:setup_user] ||= "root"
    params[:setup_password] ||= node[:mysql][:server_root_password]

    init_filename = "/tmp/init-#{params[:name]}.sql"

    file init_filename do
      action :nothing
    end

    execute "Initialize #{params[:name]} database" do
      cmd = "mysql -h #{params[:host]} "
      cmd << "-u #{params[:setup_user]} "
      unless params[:setup_password] == ""
        cmd << "-p#{params[:setup_password]} "
      end
      cmd << "#{params[:name]} <#{init_filename}"

      command cmd
      action :nothing
      notifies :delete, resources(:file => init_filename), :immediately
    end

    template init_filename do
      source "init.sql.erb"
      variables(
        :params => params,
        :fqdn => node[:fqdn]
      )
      action :nothing
      notifies :run, resources(:execute => "Initialize #{params[:name]} database"), :immediately
    end
  end
end