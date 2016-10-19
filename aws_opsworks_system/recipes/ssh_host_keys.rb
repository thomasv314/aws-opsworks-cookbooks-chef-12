# For imported ec2 instances it is possible that there will
# be null values for the host ssh keys.

host_keys = {
  "ssh_host_rsa_key" => find_instance["ssh_host_rsa_key_private"],
  "ssh_host_rsa_key.pub" => find_instance["ssh_host_rsa_key_public"],
  "ssh_host_dsa_key" => find_instance["ssh_host_dsa_key_private"],
  "ssh_host_dsa_key.pub" => find_instance["ssh_host_dsa_key_public"]
}

host_keys.each do |key_file, key_content|
  if key_content
    key_mode = key_file.end_with?(".pub") ? "644" : "0600"
    file "/etc/ssh/#{key_file}" do
      content key_content
      mode key_mode
    end
  end
end
