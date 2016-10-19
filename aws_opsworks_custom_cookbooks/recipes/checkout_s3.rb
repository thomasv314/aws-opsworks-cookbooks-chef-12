custom_cookbooks_source = node["aws_opsworks_agent"]["resources"]["stack"]["custom_cookbooks_source"]

package "unzip" do
  retries 2
end

tmp_download_location = File.join(Chef::Config["file_cache_path"], "custom_cookbook_archive_s3")
s3_bucket, s3_key, base_url = OpsWorks::SCM::S3.parse_uri(custom_cookbooks_source["url"])

s3_file tmp_download_location do
  bucket s3_bucket
  remote_path s3_key
  s3_url base_url
  aws_access_key_id custom_cookbooks_source["username"]
  aws_secret_access_key custom_cookbooks_source["password"]
  owner "root"
  group "root"
  mode "0600"
  action :create
end

execute "extract files" do
  command "/opt/aws/opsworks/current/bin/extract '#{tmp_download_location}' '#{node["aws_opsworks_custom_cookbooks"]["destination"]}'"
end
