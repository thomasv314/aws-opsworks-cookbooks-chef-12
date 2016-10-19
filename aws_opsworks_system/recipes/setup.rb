if !on_premises? && AWS::OpsWorks::System::Helper.swap_needed?(node["memory"]["total"])
  include_recipe "aws_opsworks_system::swap"
end

include_recipe "aws_opsworks_system::ssh_host_keys" unless on_premises?
include_recipe "aws_opsworks_system::chef"

include_recipe "aws_opsworks_system::ldconfig"
include_recipe "aws_opsworks_system::yum"
include_recipe "aws_opsworks_system::ntp" if platform?("ubuntu")
