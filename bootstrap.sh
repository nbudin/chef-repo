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

cat <<EOF >server-config.json
{
    "ec2" : { },
    "rails_apps" :
      { 
        "radiant" : {
          "db" : {
            "type": "mysql",
            "server": "localhost",
            "database": "radiant_production",
            "user": "root",
            "password": ""
          },
          "repo": "http://github.com/radiant/radiant.git"
        }
      },
    "recipes": ["passenger_nginx", "rails_app"]
}
EOF

chef-solo -j server-config.json
