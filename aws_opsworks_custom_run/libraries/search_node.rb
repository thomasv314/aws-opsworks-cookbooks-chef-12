module AWS
  module OpsWorks
    module Agent
      class SearchNode

        attr_reader :instance_attribs, :resources_attribs, :fqdn, :domain, :layer_shortnames

        def initialize(instance_attribs, resources_attribs, domain = nil)
          @instance_attribs = instance_attribs
          @resources_attribs = resources_attribs
          @domain = domain
          @fqdn = domain ? "#{instance_attribs["hostname"]}.#{domain}" : instance_attribs["hostname"]

          @layer_shortnames = instance_attribs["layer_ids"].map do |layer_id|
            resources_attribs["layers"].detect{|layer| layer["layer_id"] == layer_id}["shortname"]
          end

          @search_node = blueprint
          @search_node["default"].merge!(opsworks_partial)
          @search_node["default"].merge!(ohai_partial)
          @search_node.merge!(run_list_partial)
        end

        def [](attrib)
          @search_node[attrib]
        end

        def to_json
          JSON.pretty_generate(@search_node)
        end

        private

        def os
          @os ||= case platform_family
                  when "rhel", "debian"
                    "linux"
                  else
                    "unknown"
                  end
        end

        def platform
          @platform ||= instance_attribs["os"].split(" ")[0].downcase
        rescue
          "unknown"
        end

        def platform_family
          @platform_family ||= case platform
                               when "amazon", "redhat", "centos", "scientific"
                                 "rhel"
                               when "ubuntu", "debian"
                                 "debian"
                               else
                                 "unknown"
                               end
        end

        def blueprint
          {
            "name" => instance_attribs["hostname"],
            "default" => {},
            "automatic" => {
              "roles" => []
            },
            "run_list" => []
          }
        end

        def opsworks_partial
          {
            "aws_opsworks_instance_id" => instance_attribs["instance_id"]
          }
        end

        def ohai_partial
          ohai_partial_data = {
            "hostname" => instance_attribs["hostname"],
            "os" => os,
            "platform" => platform,
            "platform_family" => platform_family,
            "ipaddress" => instance_attribs["private_ip"],
            "fqdn" => fqdn,
            "domain" => domain,
            "network" => {
              "interfaces" => {
                "aws_opsworks_virtual" => {
                  "addresses" => {
                    instance_attribs["private_ip"] => {
                      "family" => "inet"
                    }
                  }
                }
              }
            },
            "kernel" => {
              "machine" => instance_attribs["architecture"]
            },
            "cloud" => {
              "public_ips" => [
                instance_attribs["public_ip"]
              ],
              "private_ips" => [
                instance_attribs["private_ip"]
              ],
              "public_hostname" => instance_attribs["public_dns"],
              "public_ipv4" => instance_attribs["public_ip"],
              "local_hostname" => instance_attribs["private_dns"],
              "local_ipv4" => instance_attribs["private_ip"]
            },
            "cloud_v2" => {
              "public_ipv4_addrs" => [
                instance_attribs["public_ip"]
              ],
              "local_ipv4_addrs" => [
                instance_attribs["private_ip"]
              ],
              "public_hostname" => instance_attribs["public_dns"],
              "public_ipv4" => instance_attribs["public_ip"],
              "local_hostname" => instance_attribs["private_dns"],
              "local_ipv4" => instance_attribs["private_ip"]
            }
          }

          if instance_attribs["ec2_instance_id"]
            ohai_partial_data.merge!(
              {
                "ec2" => {
                  "ami_id" => instance_attribs["ami_id"],
                  "hostname" => instance_attribs["private_dns"],
                  "instance_id" => instance_attribs["ec2_instance_id"],
                  "instance_type" => instance_attribs["instance_type"],
                  "local_hostname" => instance_attribs["private_dns"],
                  "local_ipv4" => instance_attribs["private_ip"],
                  "placement_availability_zone" => instance_attribs["availability_zone"],
                  "public_hostname" => instance_attribs["public_dns"],
                  "public_ipv4" => instance_attribs["public_ip"]
                }
              }
            )
            ohai_partial_data["cloud"]["provider"] = "ec2"
            ohai_partial_data["cloud_v2"]["provider"] = "ec2"
          end

          ohai_partial_data
        end

        def run_list_partial
          {
            "run_list" => layer_shortnames.map{|name| "role[#{name}]"}
          }
        end

      end
    end
  end
end
