require "tmpdir"

Dir.glob(File.join(Dir.tmpdir, "opsworks*")).each do |file|
  if File.directory?(file)
    directory file do
      recursive true
      action :delete
    end
  else
    file file do
      action :delete
      backup false
    end
  end
end

if File.exist?(node["aws_opsworks_system"]["cleanup"]["log_dir"])
  files = Dir.glob(File.join(node["aws_opsworks_system"]["cleanup"]["log_dir"], "*.{log,json}")).sort
  files_to_delete = files[0, files.size - (node["aws_opsworks_system"]["cleanup"]["keep_logs"] * 2)] || []

  Chef::Log.info("Cleaning up #{files_to_delete.size} from #{node["aws_opsworks_system"]["cleanup"]["log_dir"]}")

  files_to_delete.each do |afile|
    file afile do
      action :delete
      backup false
    end
  end
end

if File.exist?(node["aws_opsworks_system"]["cleanup"]["customer_run_dir"])
  files = Dir.glob(File.join(node["aws_opsworks_system"]["cleanup"]["customer_run_dir"], "*")).sort_by { |c| File.stat(c).ctime }
  files_to_delete = files[0, files.size - node["aws_opsworks_system"]["cleanup"]["keep_logs"]] || []

  log("Cleaning up #{files_to_delete.size} from #{node["aws_opsworks_system"]["cleanup"]["customer_run_dir"]}")

  files_to_delete.each do |afile|
    directory afile do
      recursive true
      action :delete
    end
  end
end
