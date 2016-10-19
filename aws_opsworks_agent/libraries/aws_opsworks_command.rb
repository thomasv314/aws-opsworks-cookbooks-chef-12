module AWS
  module OpsWorks
    module Agent
      class Command

        GRANT_ACCESS ||= "grant_remote_access"
        REVOKE_ACCESS ||= "revoke_remote_access"
        IGNORED_COMMANDS ||= []
        SETUP_COMMANDS ||= ["setup"]
        UPDATE_COOKBOOKS_COMMANDS ||= ["setup", "update_custom_cookbooks"]
        private_constant :GRANT_ACCESS, :REVOKE_ACCESS, :IGNORED_COMMANDS, :SETUP_COMMANDS, :UPDATE_COOKBOOKS_COMMANDS
        attr_reader :type

        def initialize(type)
          @type = type
        end

        def ignored?
          IGNORED_COMMANDS.include? @type
        end

        def allows_setup?
          SETUP_COMMANDS.include? @type
        end

        def allows_update_cookbooks?
          UPDATE_COOKBOOKS_COMMANDS.include? @type
        end

        def grant_access?
          GRANT_ACCESS == @type
        end

        def revoke_access?
          REVOKE_ACCESS == @type
        end
      end
    end
  end
end
