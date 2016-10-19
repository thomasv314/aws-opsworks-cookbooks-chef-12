file File.join(File.join("/", "var", "lib", "aws", "opsworks", "TARGET_VERSION")) do
  content "#{node["aws_opsworks_agent"]["version"]}\n"
  backup false
  owner "aws"
  group "aws"
  mode "0600"
end
