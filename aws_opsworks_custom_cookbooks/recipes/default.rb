# Deletes the existing custom cookbooks if they exist
# and checks out a fresh copy

use_custom_cookbooks = node["aws_opsworks_agent"]["resources"]["stack"]["use_custom_cookbooks"]
cookbook_destination = node["aws_opsworks_custom_cookbooks"]["destination"]

# Always delete existing custom cookbooks if they exist
directory "default #{cookbook_destination}" do
  path cookbook_destination
  action :delete
  recursive true
  only_if { File.exists?(cookbook_destination) }
end

if use_custom_cookbooks
  include_recipe "aws_opsworks_custom_cookbooks::checkout"
end
