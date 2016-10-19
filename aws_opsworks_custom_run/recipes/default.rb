command_id = node["aws_opsworks_agent"]["command"]["command_id"]

aws_opsworks_custom_run command_id do
  base_dir node["aws_opsworks_custom_run"]["base_dir"]
  cookbook_path node["aws_opsworks_custom_run"]["cookbook_path"]
end
