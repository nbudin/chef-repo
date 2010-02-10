#!/bin/sh

RUBY_ENTERPRISE_URL=http://rubyforge.org/frs/download.php/68718/ruby-enterprise_1.8.7-2010.01_i386.deb

apt-get -y install git-core build-essential
wget -O /tmp/ruby-enterprise.deb $RUBY_ENTERPRISE_URL
dpkg -i /tmp/ruby-enterprise.deb

gem update --system --no-ri --no-rdoc
gem update --no-ri --no-rdoc
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
    "gitosis" : {
      "admin_key" : "ssh-dss AAAAB3NzaC1kc3MAAACBANjHDnv/lnL/9Cd0x39wJM4ROI0lsNKLPOAn50G2Y1eZZDKBKR3mowxiDPDdQWLyvkTyHO9maqR1xytWEZnDH6gnz/K0aaWtgIDI25rEonsVpOliDlgl1NoLWIeu7HygaJZdRKzpyF2gfD+ibuPO5NfOoSqogZHXFocmRSrEJ+kzAAAAFQCrsZbb2qB/w1ZRofQvLsJMbKyhtQAAAIB6TmeVrn2MymgrPWxcKXkst8JePgVOJpb0HapAi0v8Zfdk7pBQrvazMHihoY3Pl3587N+5OOAiLakBjBuLh7asB7THoXRG/bg85vzh60cfcG9dsrZjYdlViTuPbJAiFknIOBvJb3hzZ55EL0qh346WtwIhUs2aWYZ+/yuQ/L4MegAAAIEAnAFk9j7vECU0jqBcWiN/zkQlm/4RFzr/Z9du8xNjrR6JTNfV0mKBLLqGdn+HqbzY7fZ1mOChWNOhy+IJhsQ8Vdnf/qoeVobqkXWJc86OzeuSdRmiz4QqCOZH0basfhZJqdcA7fu6VYSHqBnCN6BNuOak5VcsDq9Mb1rsZIDxsgM= nbudin@nakamura"
    },
    "postfix" : {
      "mail_type" : "master"
    },
    "mysql" : {
      "server_root_password": ""
    },
    "backupninja" : {
      "report_email" : "natbudin@gmail.com",
      "duplicity_s3" : {
        "aws_access_key_id" : "XXXX",
        "aws_secret_access_key" : "XXXX",
        "passphrase": "XXXX",
        "target_url" : "s3+http://nbudin/backups/chef-tester"
      }
    },
    "rails_apps" :
      { 
        "radiant" : {
          "server_name": "localhost",
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
    "recipes": ["gitosis", "postfix", "mysql::server", "passenger_nginx", "backupninja", "rails_app"]
}
EOF

chef-solo -j server-config.json
