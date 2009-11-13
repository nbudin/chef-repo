#!/bin/sh

PATH=/var/lib/gems/1.8/bin:$PATH

apt-get -y install ruby git-core rubygems ruby-dev build-essential
gem sources -a http://gems.opscode.com
gem install ohai json rake --no-ri --no-rdoc
gem install chef --no-ri --no-rdoc

git clone git://github.com/nbudin/chef-repo
cd chef-repo
rake install
cd ..

echo '{' >server-config.json
echo ' "ree": { "architecture": "i386" },' >>server-config.json
echo ' "recipes": ["passenger_nginx"]' >>server-config.json
echo '}' >>server-config.json

chef-solo -j server-config.json
