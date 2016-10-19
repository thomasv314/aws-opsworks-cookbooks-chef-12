bash "create swap file #{node['aws_opsworks_system']['swapfile_name']}" do
  user 'root'
  code <<-EOC
    dd if=/dev/zero of=#{node['aws_opsworks_system']['swapfile_name']} bs=1M count=#{AWS::OpsWorks::System::Helper.swap_file_size(node["memory"]["total"])}
    mkswap #{node['aws_opsworks_system']['swapfile_name']}
    chown root:root #{node['aws_opsworks_system']['swapfile_name']}
    chmod 0600 #{node['aws_opsworks_system']['swapfile_name']}
  EOC
  creates node['aws_opsworks_system']['swapfile_name']
end

mount 'swap' do
  action :enable
  device node['aws_opsworks_system']['swapfile_name']
  fstype 'swap'
end

bash 'activate all swap devices' do
  user 'root'
  code 'swapon -a'
end
