module AWS
  module OpsWorks
    module Users
      class Collection

        attr_reader :remote_users, :administrator_users

        def initialize(users)
          @users = users
          set_remote_users
          set_administrator_users
        end

        private

        def set_remote_users
          @remote_users = @users.select { |u| u["remote_access"] }.freeze
        end

        def set_administrator_users
          @administrator_users = @users.select { |u| u["administrator_privileges"] }.freeze
        end
      end
    end
  end
end
