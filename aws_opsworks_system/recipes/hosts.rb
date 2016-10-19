template "/etc/hosts" do
  source "hosts.erb"
  mode "0644"
  variables(
    :localhost_name => find_instance["hostname"],
    :nodes => generate_hosts_entries
  )
end
