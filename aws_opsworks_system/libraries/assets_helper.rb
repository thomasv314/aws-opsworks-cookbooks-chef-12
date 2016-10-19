require "yaml"

module AWS
  module OpsWorks
    module System
      module Assets
        INSTANCE_AGENT_CONFIG ||= "/etc/aws/opsworks/instance-agent.yml"
        FALLBACK_BUCKET ||= "opsworks-instance-assets-us-east-1.s3.amazonaws.com"

        def self.url_for(key)
          "https://#{asset_bucket}/packages/#{key}"
        end

        def self.asset_bucket
          YAML.load(IO.read(INSTANCE_AGENT_CONFIG))[:assets_download_bucket]
        rescue => e
          Chef::Log.warn "Unable to read '#{INSTANCE_AGENT_CONFIG}'. Defaulting to '#{FALLBACK_BUCKET}'"
          FALLBACK_BUCKET
        end
      end
    end
  end
end
