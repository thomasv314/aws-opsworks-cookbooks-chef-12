module AWS
  module OpsWorks
    module ECS
      module Helper
        def ecs_cluster?
          find_layers.any? {|layer| layer["type"] == "ecs-cluster"}
        end

        def ecs_cluster_name
          ecs_layer = find_layers.find {|layer| layer["type"] == "ecs-cluster"}
          ecs_layer && find_ecs_cluster(ecs_layer["ecs_cluster_arn"])["ecs_cluster_name"]
        end
      end
    end
  end
end
