command = AWS::OpsWorks::Agent::Command.new(node["aws_opsworks_agent"]["command"]["type"])

if command.ignored?
  Chef::Log.info("#{command} is ignored - won't do anything here.")
else
  case command.type
  when "setup"
    include_recipe "aws_opsworks_system::setup"
    include_recipe "aws_opsworks_users"
    include_recipe "aws_opsworks_custom_cookbooks"
    include_recipe "aws_opsworks_ebs" unless on_premises?
  when "configure"
    include_recipe "aws_opsworks_users"
    include_recipe "aws_opsworks_agent_version"

  when "shutdown" # nothing to do here

  when "deploy"   # app command - empty by intent
  when "undeploy" # app command - empty by intent
  when "start"    # app command - empty by intent
  when "stop"     # app command - empty by intent
  when "restart"  # app command - empty by intent
  when "execute_recipes" # nothing to do here

  when "update_dependencies"  # this will get renamed
    include_recipe "aws_opsworks_system::update_os"

  when "update_custom_cookbooks"
    include_recipe "aws_opsworks_custom_cookbooks"

  when "sync_remote_users"
    include_recipe "aws_opsworks_users"
  end
end

include_recipe "aws_opsworks_system"
include_recipe "aws_opsworks_ecs"
include_recipe "aws_opsworks_custom_cookbooks::create_or_delete"
include_recipe "aws_opsworks_custom_run"
