default["aws_opsworks_custom_run"]["base_dir"] = "/var/chef"
default["aws_opsworks_custom_run"]["cookbook_path"] = [ "/var/chef/cookbooks" ]

include_attribute "aws_opsworks_system"
