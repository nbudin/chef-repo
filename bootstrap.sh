#!/bin/sh

RUBY_ENTERPRISE_URL=http://rubyforge.org/frs/download.php/68720/ruby-enterprise_1.8.7-2010.01_amd64.deb

apt-get -y install build-essential cron
wget -O /tmp/ruby-enterprise.deb $RUBY_ENTERPRISE_URL
dpkg -i /tmp/ruby-enterprise.deb

gem update --system --no-ri --no-rdoc
gem update --no-ri --no-rdoc
gem sources -a http://gems.opscode.com
gem install ohai json rake --no-ri --no-rdoc
gem install chef --no-ri --no-rdoc

mkdir -p /etc/chef
cat <<EOF >/etc/chef/client.rb
log_level          :info
log_location       "/var/log/chef/client.log"
ssl_verify_mode    :verify_none
registration_url   "http://socrates.sugarpond.net:80"
openid_url         "http://socrates.sugarpond.net:80"
template_url       "http://socrates.sugarpond.net:80"
remotefile_url     "http://socrates.sugarpond.net:80"
search_url         "http://socrates.sugarpond.net:80"
role_url           "http://socrates.sugarpond.net:80"

file_cache_path    "/srv/chef/cache"

pid_file           "/var/run/chef/chef-client.pid"

Chef::Log::Formatter.show_time = false
EOF

cat <<EOF >/etc/cron.d/chef-client
# /etc/cron.d/chef-client - run chef-client every 30 mins

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

0,30 * * * * root if [ -x /usr/local/bin/chef-client ]; then /usr/local/bin/chef-client -s 60; fi
EOF
