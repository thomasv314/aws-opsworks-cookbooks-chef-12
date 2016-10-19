package "docker" do
  retries 2
end

service "docker" do
  action :start
end

package "ecs-init" do
  retries 2
end

service "ecs" do
  action :start

  provider Chef::Provider::Service::Upstart
end
