module AWS
  module OpsWorks
    module CustomRun
      COMMAND_RECIPES_BLACKLIST ||= {
        :execute_recipes => ["aws_opsworks_agent_version", "aws_opsworks_users"]
      }.freeze

      def self.filter_run_list_entries(command, run_list)
        return [] unless run_list

        filtered_run_list = run_list.dup
        filtered_run_list -= COMMAND_RECIPES_BLACKLIST.fetch(command.to_sym, [])
        return filtered_run_list
      end

      def self.filtered_run_list(command_type, customer_recipes)
        list = filter_run_list_entries(command_type, customer_recipes)
        list.map{|recipe| "recipe[#{recipe}]"}
      end

      def self.sanitize(name)
        name.gsub(/[^0-9A-z.\-]/, "_")
      end
    end
  end
end
