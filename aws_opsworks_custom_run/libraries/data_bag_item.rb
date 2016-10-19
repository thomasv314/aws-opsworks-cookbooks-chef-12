module AWS
  module OpsWorks
    module Agent
      class DataBagItem

        attr_reader :data_bag_item

        def initialize(resource, opsworks_attribs)
          @data_bag_item = Hash[resource.to_a]

          enrich_attributes(opsworks_attribs)
        end

        def [](attrib)
          data_bag_item[attrib]
        end

        def to_json
          JSON.pretty_generate(data_bag_item)
        end

        private

        def enrich_attributes(opsworks_attribs)
        end

      end

      class AppDataBagItem < DataBagItem

        private

        def enrich_attributes(opsworks_attribs)
          apps_to_deploy = opsworks_attribs["command"]["args"]["app_ids"]
          data_bag_item["deploy"] = true if apps_to_deploy && apps_to_deploy.include?(data_bag_item["app_id"])
        end

      end

      class InstanceDataBagItem < DataBagItem

        private

        def enrich_attributes(opsworks_attribs)
          data_bag_item["role"] = data_bag_item["layer_ids"].map do |layer_id|
            opsworks_attribs["resources"]["layers"].detect{|layer| layer["layer_id"] == layer_id}["shortname"]
          end
          data_bag_item["self"] = opsworks_attribs["command"]["instance_id"] == data_bag_item["instance_id"]
        end

      end

      class CommandDataBagItem < DataBagItem
      end

      class LayerDataBagItem < DataBagItem
      end

      class StackDataBagItem < DataBagItem
      end

      class UserDataBagItem < DataBagItem
      end

      class ElasticLoadBalancerDataBagItem < DataBagItem
      end

      class RdsDbInstanceDataBagItem < DataBagItem
      end

      class EcsClusterDataBagItem < DataBagItem
      end
    end
  end
end
