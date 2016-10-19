::Chef::Resource::Template.send(:include, AWS::OpsWorks::ECS::Helper)
::Chef::Resource::RubyBlock.send(:include, AWS::OpsWorks::ECS::Helper)

directory "/etc/ecs" do
  action :create
  owner "root"
  mode 0755
end

template "ecs.config" do
  path "/etc/ecs/ecs.config"
  source "ecs.config.erb"
  variables :ecs_cluster_name => ecs_cluster_name
  owner "root"
  group "root"
  mode 0644
end

directory "/var/lib/ecs/data" do
  action :create
  owner "root"
  mode 0755
  recursive true
end

directory "/var/log/ecs" do
  action :create
  owner "root"
  mode 0755
end

group "docker" do
  action :create
end

if platform?(*node["aws_opsworks_ecs"]["supported_platforms"])
  include_recipe "aws_opsworks_ecs::setup_#{node["platform"]}"
else
  fail "The platform #{node["platform"]} is not support by OpsWorks."
end

execute "Install the Amazon ECS agent" do
  command ["/usr/bin/docker",
           "run",
           "--name ecs-agent",
           "-d",
           "-v /var/run/docker.sock:/var/run/docker.sock",
           "-v /var/log/ecs:/log",
           "-v /var/lib/ecs/data:/data",
           "-p 127.0.0.1:51678:51678",
           "--env-file /etc/ecs/ecs.config",
           "amazon/amazon-ecs-agent:latest"].join(" ")

  only_if do
    ::File.exist?("/usr/bin/docker") && !OpsWorks::ShellOut.shellout("docker ps -a").include?("amazon-ecs-agent")
  end

  retries 1
  retry_delay 5
end

ruby_block "Check that the ECS agent is running" do
  block do
    ecs_agent = AWS::OpsWorks::ECSAgent.new

    unless ecs_agent.wait_for_availability
      logs = OpsWorks::ShellOut.shellout("docker logs ecs-agent")
      fail "ECS agent failed to start.\nRunning 'docker logs ecs-agent':\n#{logs}"
    end

    fail "ECS agent is registered to a different cluster." unless ecs_agent.cluster == ecs_cluster_name
  end
end
