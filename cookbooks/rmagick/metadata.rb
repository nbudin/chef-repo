maintainer       "Nat Budin"
maintainer_email "nat@sugarpond.net"
description      "Installs rmagick on Debian/Ubuntu (because the gem has external lib dependencies)"
version          "0.1"

%w{ ubuntu debian }.each do |os|
  supports os
end
