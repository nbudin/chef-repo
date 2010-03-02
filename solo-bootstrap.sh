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

apt-get -y install git-core
git clone http://github.com/nbudin/chef-repo.git
cd chef-repo
rake install
cd ..

cat <<EOF >solo.json
{
  run_list: ["recipe[mysql::server]"]
}
EOF
