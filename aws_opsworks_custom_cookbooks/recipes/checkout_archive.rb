package "unzip"

tmp_download_location = File.join(Chef::Config["file_cache_path"], "custom_cookbook_archive_archive")
custom_cookbooks_source = node["aws_opsworks_agent"]["resources"]["stack"]["custom_cookbooks_source"]

if !(custom_cookbooks_source["username"].nil? || custom_cookbooks_source["username"].empty?) &&
   !(custom_cookbooks_source["password"].nil? || custom_cookbooks_source["password"].empty?)
  archive_url = URI.parse(custom_cookbooks_source["url"])
  archive_url.user = custom_cookbooks_source["username"]
  archive_url.password = custom_cookbooks_source["password"]
  archive_url = archive_url.to_s
else
  archive_url = custom_cookbooks_source["url"]
end

remote_file tmp_download_location do
  source archive_url
  retries 3
end

execute "extract files" do
  command "/opt/aws/opsworks/current/bin/extract '#{tmp_download_location}' '#{node["aws_opsworks_custom_cookbooks"]["destination"]}'"
end
