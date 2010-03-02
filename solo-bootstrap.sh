#!/bin/sh

RUBY_ENTERPRISE_URL=http://rubyforge.org/frs/download.php/68720/ruby-enterprise_1.8.7-2010.01_amd64.deb

sudo apt-get -y install build-essential cron
wget -O /tmp/ruby-enterprise.deb $RUBY_ENTERPRISE_URL
sudo dpkg -i /tmp/ruby-enterprise.deb

sudo gem update --system --no-ri --no-rdoc
sudo gem update --no-ri --no-rdoc
sudo gem sources -a http://gems.opscode.com
sudo gem install ohai json rake --no-ri --no-rdoc
sudo gem install chef --no-ri --no-rdoc

sudo apt-get -y install git-core
git clone http://github.com/nbudin/chef-repo.git

sudo mkdir -p /etc/chef
echo <<EOSCRIPT |sudo /bin/bash

cat <<EOF >/etc/chef/solo.rb
file_cache_path "/tmp/chef-solo"
cookbook_path "$(pwd)/chef-repo/cookbooks"
EOF
EOSCRIPT

cat <<EOF >solo.json
{
  run_list: ["recipe[mysql::server]"]
}
EOF
