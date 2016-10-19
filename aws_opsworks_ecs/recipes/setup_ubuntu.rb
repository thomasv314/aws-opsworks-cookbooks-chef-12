file "/etc/apt/sources.list.d/docker.list" do
  content "deb #{node["aws_opsworks_ecs"]["ubuntu_docker_repository"]["url"]} #{node["lsb"]["id"].downcase}-#{node["lsb"]["codename"]} #{node["aws_opsworks_ecs"]["ubuntu_docker_repository"]["component"]}"
end

key_file = "#{Chef::Config[:file_cache_path]}/#{node["aws_opsworks_ecs"]["ubuntu_docker_repository"]["fingerprint"]}.pubkey"
cookbook_file key_file do
  source "#{node["aws_opsworks_ecs"]["ubuntu_docker_repository"]["fingerprint"]}.pubkey"
end

execute "apt-get update" do
  retries 3
  retry_delay 5

  action :nothing
end

execute "Import docker repository key" do
  command "apt-key add #{key_file}"

  not_if do
    OpsWorks::ShellOut.shellout("apt-key adv --list-public-keys #{node["aws_opsworks_ecs"]["ubuntu_docker_repository"]["fingerprint"]}") rescue false
  end

  notifies :run, "execute[apt-get update]", :immediately
end

package "docker-engine" do
  retries 2
  options "--no-install-recommends"
end
