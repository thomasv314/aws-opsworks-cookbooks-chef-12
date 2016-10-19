case node["platform_family"]
when "rhel"
  os_release_version = node["aws_opsworks_agent"]["command"]["args"]["os_release_version"]
  allow_reboot = node["aws_opsworks_agent"]["command"]["args"]["allow_reboot"]

  ruby_block "upgrade the release version lock" do
    block do
      rc = Chef::Util::FileEdit.new("/etc/yum.conf")
      release_line = "releasever=#{os_release_version}"
      rc.search_file_replace_line(/^\s*releasever\s*=/, release_line)
      rc.write_file
    end
    only_if do
      os_release_version && ::File.exist?("/etc/yum.conf")
    end
  end

  execute "yum -y update" do
    action :run
  end

  execute "/sbin/shutdown -r +2 &" do
    only_if do
      installed_kernels = OpsWorks::ShellOut.shellout("rpm -q --last kernel")
      latest_installed_kernel = installed_kernels.gsub(/^kernel-(\S+).*/, "\1").lines.first.strip
      current_used_kernel = OpsWorks::ShellOut.shellout("uname -r").strip
      reboot_required = latest_installed_kernel != current_used_kernel
      if allow_reboot
        reboot_required
      elsif reboot_required && !allow_reboot
        Chef::Log.warn("reboot required but not allowed")
        false
      else
        false # not required and not allowed
      end
    end
  end

when "debian"
  execute "apt-get update" do
    action :run
  end

  execute "apt-get upgrade -y" do
    action :run
  end
end
