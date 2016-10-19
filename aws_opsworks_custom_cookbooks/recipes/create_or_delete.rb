# Creates the custom cookbooks if they do not
# already exist or deletes them if custom cookbooks are
# no longer enabled.

use_custom_cookbooks = node["aws_opsworks_agent"]["resources"]["stack"]["use_custom_cookbooks"]
cookbook_destination = node["aws_opsworks_custom_cookbooks"]["destination"]

if use_custom_cookbooks
  include_recipe "aws_opsworks_custom_cookbooks::checkout" unless File.exist?(cookbook_destination)
else
  # Delete existing custom cookbook directory if it exists
  # and custom cookbooks are disabled
  directory "create/delete #{cookbook_destination}" do
    path cookbook_destination
    action :delete
    recursive true
    only_if { File.exist?(cookbook_destination) }
  end
end
