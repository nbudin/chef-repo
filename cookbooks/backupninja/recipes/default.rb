# This only supports Debian-like distributions right now.

package "backupninja" do
  action :install
end

package "debconf-utils" do
  action :install
end

package "hwinfo" do
  action :install
end

template "/etc/backupninja.conf" do
  source "backupninja.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables(
    :report_email => node[:backupninja][:report_email]
  )
end

template "/etc/backup.d/10.sys" do
  source "10.sys.erb"
  owner "root"
  group "root"
  mode 0600
end

if node[:backupninja][:duplicity_s3]
  package "duplicity" do
    action :install
  end
  
  package "python-boto" do
    action :install
  end
  
  template "/etc/backup.d/90dup.sh" do
    source "90dup.sh.erb"
    owner "root"
    group "root"
    mode 0600

    # we can't keep backups of this because backupninja will try to run them
    backup false
    
    includes = ["/var/spool/cron/crontabs",
                "/var/backups",
                "/etc",
                "/root",
                "/home",
                "/usr/local",
                "/var/lib/dpkg/status*",
                "/opt"] +
               (node[:backupninja][:duplicity_s3][:includes] || [])
    excludes = ["/home/*/.gnupg",
                "/home/*/.Trash"] +
               (node[:backupninja][:duplicity_s3][:excludes] || []) +
               ["**"]
    
    full_every = node[:backupninja][:duplicity_s3][:full_every] || "30D"
    keep_last_full = node[:backupninja][:duplicity_s3][:keep_last_full] || 3

    target_url = node[:backupninja][:duplicity_s3][:target_url]
    if target_url
      target_url << "/" unless target_url =~ /\/$/
      target_url << node[:fqdn]
    end
    
    variables(
      :includes => includes,
      :excludes => excludes,
      :aws_access_key_id => node[:backupninja][:duplicity_s3][:aws_access_key_id],
      :aws_secret_access_key => node[:backupninja][:duplicity_s3][:aws_secret_access_key],
      :passphrase => node[:backupninja][:duplicity_s3][:passphrase],
      :target_url => target_url,
      :full_every => full_every,
      :keep_last_full => keep_last_full
    )
  end
end
