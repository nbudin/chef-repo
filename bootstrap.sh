#!/bin/sh

RUBY_ENTERPRISE_URL=http://rubyforge.org/frs/download.php/66164/ruby-enterprise_1.8.7-2009.10_i386.deb

apt-get -y install git-core build-essential
wget -O /tmp/ruby-enterprise.deb $RUBY_ENTERPRISE_URL
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

echo <<EOF >server-config.json
{
 "recipes": ["passenger_nginx"]
}
EOF

chef-solo -j server-config.json
