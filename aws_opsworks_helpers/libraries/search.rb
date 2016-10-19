def find_own_instance_id
  node["aws_opsworks_agent"]["command"]["instance_id"]
end

def find_instance(instance_id = find_own_instance_id)
  node["aws_opsworks_agent"]["resources"]["instances"].find { |i| i["instance_id"] == instance_id }
end

def find_layer_ids(instance_id = find_own_instance_id)
  find_instance(instance_id)["layer_ids"]
end

def find_layers_by_instance_id(instance_id = find_own_instance_id)
  find_layers_by_layer_ids(find_layer_ids(instance_id))
end

def find_layers(instance_id = find_own_instance_id) # alias of find_layers_by_instance_id
  find_layers_by_instance_id(instance_id)
end

def find_layers_by_layer_ids(layer_ids)
  node["aws_opsworks_agent"]["resources"]["layers"].select { |l| layer_ids.include?(l["layer_id"]) }
end

def find_stack
  node["aws_opsworks_agent"]["resources"]["stack"]
end

def find_ecs_cluster(ecs_cluster_arn)
  node["aws_opsworks_agent"]["resources"]["ecs_clusters"].find { |ecs| ecs["ecs_cluster_arn"] == ecs_cluster_arn }
end
