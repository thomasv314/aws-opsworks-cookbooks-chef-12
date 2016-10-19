module OpsWorks
  module SCM
    module S3
      def self.parse_uri(uri)
        #                base_uri                |         remote_path
        #----------------------------------------+------------------------------
        # scheme, userinfo, host, port, registry | path, opaque, query, fragment

        components = URI.split(uri)
        base_uri = URI::HTTP.new(*(components.take(5) + [nil] * 4))
        remote_path = URI::HTTP.new(*([nil] * 5 + components.drop(5)))

        virtual_host_match = base_uri.host.match(/\A(.+)\.s3(?:[-.](?:ap|eu|sa|us)-(?:.+-)\d|-external-1)?\.amazonaws\.com/i)

        if virtual_host_match
          # virtual-hosted-style: http://bucket.s3.amazonaws.com or http://bucket.s3-aws-region.amazonaws.com
          bucket = virtual_host_match[1]
        else
          # path-style: http://s3.amazonaws.com/bucket or http://s3-aws-region.amazonaws.com/bucket
          uri_path_components = remote_path.path.split("/").reject(&:empty?)
          bucket = uri_path_components.shift # cut first element
          base_uri.path = "/#{bucket}" # append bucket to base_uri
          remote_path.path = uri_path_components.join("/") # delete bucket from remote_path
        end

        # remote_path don't allow a "/" at the beginning
        # base_url don't allow a "/" at the end
        [bucket, remote_path.to_s.to_s.sub(%r{^/}, ""), base_uri.to_s.chomp("/")]
      end
    end
  end
end
