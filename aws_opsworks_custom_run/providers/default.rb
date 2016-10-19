require "base64"

def whyrun_supported?
  true
end

use_inline_resources

DATA_BAGS = {
  "aws_opsworks_app" => {
    "resource_name" => "apps",
    "name_attribute" => "shortname",
    "item_class" => AWS::OpsWorks::Agent::AppDataBagItem
  }.freeze,
  "aws_opsworks_instance" => {
    "resource_name" => "instances",
    "name_attribute" => "hostname",
    "item_class" => AWS::OpsWorks::Agent::InstanceDataBagItem
  }.freeze,
  "aws_opsworks_layer" => {
    "resource_name" => "layers",
    "name_attribute" => "shortname",
    "item_class" => AWS::OpsWorks::Agent::LayerDataBagItem
  }.freeze,
  "aws_opsworks_stack" => {
    "resource_name" => "stack",
    "name_attribute" => "stack_id",
    "item_class" => AWS::OpsWorks::Agent::StackDataBagItem
  }.freeze,
  "aws_opsworks_command" => {
    "resource_name" => "command",
    "name_attribute" => "command_id",
    "item_class" => AWS::OpsWorks::Agent::CommandDataBagItem
  }.freeze,
  "aws_opsworks_user" => {
    "resource_name" => "users",
    "name_attribute" => "username",
    "item_class" => AWS::OpsWorks::Agent::UserDataBagItem
  }.freeze,
  "aws_opsworks_elastic_load_balancer" => {
    "resource_name" => "elastic_load_balancers",
    "name_attribute" => "elastic_load_balancer_name",
    "item_class" => AWS::OpsWorks::Agent::ElasticLoadBalancerDataBagItem
  }.freeze,
  "aws_opsworks_rds_db_instance" => {
    "resource_name" => "rds_db_instances",
    "name_attribute" => "rds_db_instance_arn",
    "item_class" => AWS::OpsWorks::Agent::RdsDbInstanceDataBagItem
  }.freeze,
  "aws_opsworks_ecs_cluster" => {
    "resource_name" => "ecs_clusters",
    "name_attribute" => "ecs_cluster_arn",
    "item_class" => AWS::OpsWorks::Agent::EcsClusterDataBagItem
  }.freeze,
}.freeze

action :prepare do
  converge_by("Create resource #{new_resource}}") do
    @base_dir = new_resource.base_dir
    @runs_base_dir = ::File.join(@base_dir, "runs")
    @run_dir = ::File.join(@runs_base_dir, new_resource.command_id)
    @data_bag_path = ::File.join(@run_dir, "data_bags")
    @node_path = ::File.join(@run_dir, "nodes")

    initialize_directories
    write_chef_config
    write_attribs_json
    write_resource_data_bags
    write_customer_data_bags
    write_search_nodes
  end
end

def initialize_directories
  directory @base_dir do
    action :create
    recursive true
#    rights :full_control, "Administrators", :applies_to_children => true, :applies_to_self => true
#    inherits false
  end

  directory @runs_base_dir do
    action :create
    recursive true
  end

  directory @run_dir do
    action :create
    recursive true
  end

  directory @data_bag_path do
    action :create
    recursive true
  end

  directory @node_path do
    action :create
    recursive true
  end
end

def write_chef_config
  vars = { :cookbook_path => new_resource.cookbook_path, :data_bag_path => @data_bag_path, :node_path => @node_path }

  template ::File.join(@run_dir, "client.rb") do
    source "client.rb.erb"
    variables vars
  end
end

def write_attribs_json

  file ::File.join(@run_dir, "attribs.json") do
    content JSON.pretty_generate(customer_attribs_with_run_list)
    sensitive true
  end
end

def write_resource_data_bags
  DATA_BAGS.each do |data_bag, data_bag_attribs|
    individual_data_bag_path = ::File.join(@data_bag_path, data_bag)

    directory individual_data_bag_path do
      action :create
      recursive true
    end

    write_data_bag_items(
      individual_data_bag_path,
      data_bag_attribs["resource_name"],
      data_bag_attribs["name_attribute"],
      data_bag_attribs["item_class"]
    )
  end
end

def write_customer_data_bags
  data_bags = if node["aws_opsworks_agent"]["chef"].key?("customer_data_bags")
                JSON.parse(Base64.decode64(node["aws_opsworks_agent"]["chef"]["customer_data_bags"]))
              else
                Chef::Log.info "No customer data bags."
                {}
              end
  fail ArgumentError, "Expected data bags to be a Hash" unless data_bags.is_a?(Hash)

  data_bags.each do |bag_name, bag_items|
    directory ::File.join(@data_bag_path, bag_name) do
      action :create
      recursive true
    end

    fail ArgumentError, "Expected data bag items to be a Hash" unless bag_items.is_a?(Hash)
    bag_items.each do |item_name, item_value|
      begin
        file ::File.join(@data_bag_path, bag_name, "#{AWS::OpsWorks::CustomRun::sanitize(item_name)}.json") do
          content JSON.pretty_generate(item_value)
          sensitive true
        end
      rescue JSON::GeneratorError => e
        fail ArgumentError, "Error writing data_bag item #{item_name.inspect} in data_bag #{bag_name.inspect}."
      end
    end
  end
end

def write_search_nodes
  if node["aws_opsworks_agent"] && node["aws_opsworks_agent"]["resources"]
    instances_to_search = node["aws_opsworks_agent"]["resources"]["instances"].select{|instance| instance["status"] == "online"}
    instances_to_search.each do |instance|
      search_node = AWS::OpsWorks::Agent::SearchNode.new(
        instance,
        node["aws_opsworks_agent"]["resources"],
        node["domain"]
      )

      determined_hostname = node["domain"] ? "#{instance["hostname"]}.#{node["domain"]}" : instance["hostname"]
      file ::File.join(@node_path, AWS::OpsWorks::CustomRun::sanitize("#{determined_hostname}.json")) do
        content search_node.to_json
        sensitive true
      end
    end
  end
end

def customer_attribs_with_run_list
  customer_attribs = JSON.parse(Base64.decode64(node["aws_opsworks_agent"]["chef"]["customer_json"]))

  if customer_attribs.key? "opsworks"
    Chef::Log.warn "Detected top-level Custom JSON entry 'opsworks'. Entry dropped."
    customer_attribs.delete("opsworks")
  end

  command_type = node["aws_opsworks_agent"]["command"]["type"]
  customer_recipes = node["aws_opsworks_agent"]["chef"]["customer_recipes"]
  customer_attribs["run_list"] = AWS::OpsWorks::CustomRun::filtered_run_list(command_type, customer_recipes)

  customer_attribs
end

def write_data_bag_items(data_bag_path, resource_type, name_attrib, clazz)
  resources_of_type = node["aws_opsworks_agent"]["resources"][resource_type]
  resources_of_type = [resources_of_type] unless resources_of_type.kind_of?(Array)

  resources_of_type.each do |resource|
    data_bag_item = clazz.new(resource, node["aws_opsworks_agent"])

    file ::File.join(data_bag_path, AWS::OpsWorks::CustomRun::sanitize("#{resource[name_attrib]}.json")) do
      content data_bag_item.to_json
    end
  end
rescue NoMethodError
  Chef::Log.info("Failed to access AWS OpsWorks resource of type #{resource_type} - ignoring it.")
end
