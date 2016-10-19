package "xfsprogs" do
  # RedHat 6 does not provide xfsprogs
  not_if { rhel6? }
  retries 2
end

node["aws_opsworks_agent"]["resources"]["volumes"].each do |options|
  device_name_guess = options[:device].sub(/sd/, "xvd")

  if rhel6?
    log "skipping volume #{device_name_guess} - no EBS volume support for Red Hat Enterprise Linux 6"
    next
  end

  execute "mkfs #{device_name_guess}" do
    command "mkfs -t #{options[:fstype] || "xfs"} #{device_name_guess}"

    only_if do
      BlockDevice.wait_for(device_name_guess)

      # check volume filesystem
      command = "blkid -s TYPE -o value #{device_name_guess}"
      cmd = Mixlib::ShellOut.new(command)
      cmd.run_command
      cmd.error?
    end
  end

  if options[:mount_point].nil? || options[:mount_point].empty?
    log "skip mounting volume #{device_name_guess} because no mount_point specified"
    next
  end

  directory options[:mount_point] do
    recursive true
    action :create
    mode "0755"
  end

  ruby_block "add xfs to list of known filesystems" do
    block do
      # xfs needs to be added before iso9660
      # otherwise xfs will get mounted read only after reboot
      file = "/etc/filesystems"
      lines = File.readlines(file).map(&:strip)
      xfs_i = lines.index("xfs")
      if xfs_i.nil?
        iso_i = lines.index("iso9660")
        if iso_i.nil? # iso9660 ot in file - append xfs at the end
          lines << "xfs"
        else # add before iso9660
          lines.insert(iso_i, "xfs")
        end

        File.write(file, lines.join("\n"))
      end
    end
    only_if { ::File.exist?("/etc/filesystems") }
  end

  mount options[:mount_point] do
    action [:mount, :enable]
    fstype options[:fstype] || "auto"
    device device_name_guess
    options value_for_platform(
      %w(debian ubuntu) => { "default" => "relatime,nobootwait", "16.04" => nil },
      "default" => "relatime"
    )
    pass 0
  end
end
