#!/bin/sh

RUBY_ENTERPRISE_URL=http://rubyforge.org/frs/download.php/66164/ruby-enterprise_1.8.7-2009.10_i386.deb

apt-get -y install git-core build-essential
curl $RUBY_ENTERPRISE_URL >/tmp/ruby-enterprise.deb
dpkg -i /tmp/ruby-enterprise.deb

gem sources -a http://gems.opscode.com
gem install ohai json rake --no-ri --no-rdoc
gem install chef --no-ri --no-rdoc

git clone git://github.com/nbudin/chef-repo
cd chef-repo
rake install
cd ..

echo 'file_cache_path "/tmp/chef-solo"' >/etc/chef/solo.rb
echo 'cookbook_path "/srv/chef/cookbooks"' >>/etc/chef/solo.rb

echo '{' >server-config.json
echo ' "ree": { "architecture": "i386" },' >>server-config.json
echo ' "recipes": ["passenger_nginx"]' >>server-config.json
echo '}' >>server-config.json

chef-solo -j server-config.json
