maintainer       "Nat Budin"
maintainer_email "nat@sugarpond.net"
description      "Installs gitosis on Debian/Ubuntu"
version          "0.1"

depends "sudo"
depends "openssh"
depends "git"

%w{ ubuntu debian }.each do |os|
  supports os
end
