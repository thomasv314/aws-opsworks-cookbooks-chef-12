custom_cookbooks_type = node["aws_opsworks_agent"]["resources"]["stack"]["custom_cookbooks_source"]["type"]

# create enclosing folder for cookbooks
directory File.dirname(node["aws_opsworks_custom_cookbooks"]["destination"]) do
  action :create
  recursive true
end

case custom_cookbooks_type
when "git"
  include_recipe "aws_opsworks_custom_cookbooks::checkout_git"
when "archive"
  include_recipe "aws_opsworks_custom_cookbooks::checkout_archive"
when "s3"
  include_recipe "aws_opsworks_custom_cookbooks::checkout_s3"
else
  fail "unsupported SCM type #{custom_cookbooks_type.inspect}"
end

ruby_block "Move single cookbook contents into appropriate subdirectory" do
  block do
    metadata_rb = File.readlines(File.join(node["aws_opsworks_custom_cookbooks"]["destination"], "metadata.rb"))
    cookbook_name = metadata_rb.detect { |line| line.match(/^\s*name\s+\S+$/) }[/name\s+['"]([^'"]+)['"]/, 1]
    cookbook_path = File.join(node["aws_opsworks_custom_cookbooks"]["destination"], cookbook_name)
    Chef::Log.info "Single cookbook detected, moving into subdirectory '#{cookbook_path}'"
    FileUtils.mkdir(cookbook_path)
    Dir.glob(File.join(node["aws_opsworks_custom_cookbooks"]["destination"], "*"), File::FNM_DOTMATCH).each do |cookbook_content|
      FileUtils.mv(cookbook_content, cookbook_path, :force => true)
    end
  end

  only_if do
    ::File.exist?(metadata = File.join(node["aws_opsworks_custom_cookbooks"]["destination"], "metadata.rb")) && File.read(metadata).match(/^\s*name\s+\S+$/)
  end
end

execute "ensure correct permissions of custom cookbooks" do
  command "chmod -R go-rwx #{node["aws_opsworks_custom_cookbooks"]["destination"]}"
  only_if do
    ::File.exist?(node["aws_opsworks_custom_cookbooks"]["destination"])
  end
end
