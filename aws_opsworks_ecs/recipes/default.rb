::Chef::Recipe.send(:include, AWS::OpsWorks::ECS::Helper)

if ecs_cluster?
  command = node["aws_opsworks_agent"]["command"]["type"]

  include_recipe "aws_opsworks_ecs::#{command}" if %w(setup shutdown).include?(command)
end
