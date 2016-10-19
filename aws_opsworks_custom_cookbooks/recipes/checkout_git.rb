custom_cookbooks_source = node["aws_opsworks_agent"]["resources"]["stack"]["custom_cookbooks_source"]

package "git" do
  package_name value_for_platform_family(
    "debian" => "git-core",
    "rhel" => "git"
  )
  retries 2
end

ssh_wrapper = "ssh"

unless custom_cookbooks_source["ssh_key"].nil? || custom_cookbooks_source["ssh_key"].empty?
  ssh_identity_file = ::File.join(Chef::Config["file_cache_path"], "git_ssh_key")
  ssh_wrapper = ::File.join(Chef::Config["file_cache_path"], "ssh_wrapper.sh")

  file ssh_identity_file do
    owner "root"
    group "root"
    mode "0600"
    content custom_cookbooks_source["ssh_key"]
  end

  file ssh_wrapper do
    owner "root"
    group "root"
    mode "0700"
    content "#!/usr/bin/env bash\nssh -i #{ssh_identity_file} -oUserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -o ConnectTimeout=30 \"$@\""
  end
end

git "Download Custom Cookbooks" do
  depth nil

  destination node["aws_opsworks_custom_cookbooks"]["destination"]

  user "root"
  group "root"

  revision custom_cookbooks_source["revision"]
  repository custom_cookbooks_source["url"]

  action :checkout
  ssh_wrapper ssh_wrapper

  retries 5
  retry_delay 10
  notifies :run, "execute[Update custom cookbook Git submodules]", :immediately
end

# This resource is a workaround for no retries on submodules checkout.
# It gets only executed only when the git checkout changes (see above).
# Without this block a git checkout fails if the submodule fails and then gets
# retried but without submodules. This means submodule checkout silently fails.
# chef ticket: https://tickets.opscode.com/browse/CHEF-4750
execute "Update custom cookbook Git submodules" do
  command "GIT_SSH=#{ssh_wrapper} git submodule update --init --recursive"
  action :nothing

  user "root"
  group "root"
  cwd node["aws_opsworks_custom_cookbooks"]["destination"]
  retries 5
  retry_delay 10
end
