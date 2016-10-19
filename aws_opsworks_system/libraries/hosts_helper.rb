def generate_hosts_line_for(i, ip_field, postfix = "")
  return unless i.key?(ip_field) && i[ip_field] && i.key?("hostname") && i["hostname"]
  if node["domain"]
    [i[ip_field], [i["hostname"] + "." + node["domain"] + postfix, i["hostname"] + postfix]]
  else
    [i[ip_field], [i["hostname"] + postfix]]
  end
end

def generate_hosts_entries
  node["aws_opsworks_agent"]["resources"]["instances"].flat_map do |instance|
    [
      generate_hosts_line_for(instance, "private_ip"),
      generate_hosts_line_for(instance, "public_ip", "-ext")
      # NOTE: This public_ip will use the the elastic ip even when there is a separate elastic_ip field in instance
    ]
  end.compact
end
