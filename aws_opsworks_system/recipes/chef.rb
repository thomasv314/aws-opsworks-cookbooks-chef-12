chef_version = node["aws_opsworks_system"]["packages"]["chef_version"]
asset_key =
  if platform?("ubuntu")
    "ubuntu/14.04/chef_#{chef_version}-1_amd64.deb"
  elsif platform?("amazon")
    "redhat/6/chef-#{chef_version}-1.el6.x86_64.rpm"
  elsif rhel6?
    "redhat/6/chef-#{chef_version}-1.el6.x86_64.rpm"
  elsif rhel7?
    "redhat/7/chef-#{chef_version}-1.el7.x86_64.rpm"
  else
    fail format("Can't find valid download key for %s %s %s for Chef version %s", node["platform_family"], node["platform"], node["platform_version"], chef_version)
  end
asset_url = AWS::OpsWorks::System::Assets.url_for(asset_key)
download_target = File.join(Chef::Config["file_cache_path"], File.basename(asset_key))

remote_file download_target do
  source asset_url
  retries 6
  retry_delay 10
  backup false
end

package "chef-client" do
  source download_target
  # default provider is apt which can't handle source attribute
  provider Chef::Provider::Package::Dpkg if platform?("ubuntu")
  retries 2
end

directory File.dirname(node["aws_opsworks_system"]["ohai_ec2_hints_file"]) do
  recursive true
  only_if { find_instance["infrastructure_class"] == "ec2" }
end

file node["aws_opsworks_system"]["ohai_ec2_hints_file"] do
  action :touch
  only_if { find_instance["infrastructure_class"] == "ec2" }
  mode 0444
end
