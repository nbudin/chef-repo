ree_filename = ["ruby-enterprise", node[:ree][:version], node[:ree][:architecture]].join("_")+".deb"

remote_file "/tmp/#{ree_filename}" do
  source ree_filename
end

package "ruby-enterprise" do
  action :upgrade
  source "/tmp/#{ree_filename}"
end