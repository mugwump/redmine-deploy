maintainer        "alere/methodpark"
maintainer_email  "cookbooks@methodpark.de"
license           "Apache 2.0"
description       "Installs graphviz"
version           "0.0.1"

recipe "graphviz", "Installs graphviz"

%w{ubuntu debian}.each do |os|
  supports os
end
