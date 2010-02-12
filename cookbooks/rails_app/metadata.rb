maintainer       "Nat Budin"
maintainer_email "nat@sugarpond.net"
description      "Deploys Rails applications using passenger + nginx"
version          "0.1"

depends "rails"
depends "passenger_nginx"
depends "git"

%w{ ubuntu debian }.each do |os|
  supports os
end
