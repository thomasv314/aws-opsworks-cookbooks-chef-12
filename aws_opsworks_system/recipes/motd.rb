template "/etc/motd.opsworks-static" do
  source "motd.erb"
  mode "0644"
  variables(
    :stack => find_stack,
    :layers => find_layers,
    :instance => find_instance,
    :os_release => "#{node["platform"]} #{node["platform_version"]}"
  )
end
