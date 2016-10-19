include_recipe "aws_opsworks_system::hosts" unless File.exist?("/etc/aws/opsworks/skip-hosts-update")
include_recipe "aws_opsworks_system::motd" unless File.exist?("/etc/aws/opsworks/skip-motd-update")
include_recipe "aws_opsworks_system::cleanup"
