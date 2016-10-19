group "opsworks"

# .fetch - for chefspec mocking
ow_gid = node.fetch("etc", {}).fetch("group", {}).fetch("opsworks", {}).fetch("gid", nil)
# node["etc"]["groups"]["opsworks"]["members"] will not report user with primary group opsworks
ow_members = node.fetch("etc", {}).fetch("passwd", {}).select { |_name, u| u["gid"].to_s == ow_gid.to_s }

# delete old users
ow_members.each do |name, existing_user|
  unless node["aws_opsworks_agent"]["resources"]["users"].any? { |u| u["unix_user_id"].to_s == existing_user["uid"].to_s }
    teardown_user(name)
  end
end

# create new users/modify existing
node["aws_opsworks_agent"]["resources"]["users"].each do |user|
  existing_name, existing_user = node["etc"]["passwd"].find { |_name, u| u["uid"].to_s == user["unix_user_id"].to_s }

  if !existing_user
    setup_user(user)
  elsif existing_name != user["username"]
    rename_user(existing_name, user["username"])
  end

  set_public_key(user)
end

users = AWS::OpsWorks::Users::Collection.new(node["aws_opsworks_agent"]["resources"]["users"])
template "/etc/sudoers.d/opsworks" do
  backup false
  source "sudoers.d.erb"
  owner "root"
  group "root"
  mode 0440
  variables :sudoers => users.administrator_users
end
