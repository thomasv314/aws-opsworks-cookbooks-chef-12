module AWS
  module OpsWorks
    module User
      @@allocated_uids = []

      def setup_user(params)
        if node["etc"]["passwd"].any? { |_name, u| u["uid"] == params["unix_user_id"] }
          log "UID #{params["unix_user_id"]} is taken, not setting up user #{params["username"]}" do
            level :info
          end
        elsif node["etc"]["passwd"].include?(params["username"])
          log "Username #{params["username"]} is taken, not setting up user #{params["username"]}" do
            level :info
          end
        else
          user params["username"] do
            action :create
            comment "OpsWorks user #{params["username"]}"
            uid params["unix_user_id"]
            gid "opsworks"
            home "/home/#{params["username"]}"
            supports :manage_home => true
            shell "/bin/bash"
          end
        end
      end

      def set_public_key(params)
        directory "/home/#{params["username"]}/.ssh" do
          owner params["username"]
          group "opsworks"
          mode 0700
          only_if do
            !params["ssh_public_key"].nil?
          end
        end

        file "/home/#{params[:username]}/.ssh/authorized_keys" do
          owner params["username"]
          group "opsworks"
          content params["ssh_public_key"]
          only_if do
            File.directory?("/home/#{params[:username]}/.ssh") && !params["ssh_public_key"].nil?
          end
        end
      end

      def kill_user_processes(name)
        execute "kill all processes of user #{name}" do
          command "pkill -u #{name}; true"
        end
      end

      def teardown_user(name)
        kill_user_processes(name)

        user name do
          action :remove
          supports :manage_home => true
        end
      end

      def rename_user(old_name, new_name)
        kill_user_processes(old_name)

        execute "rename user from #{old_name} to #{new_name}" do
          command "usermod -l #{new_name} -d /home/#{new_name} -m #{old_name}"
        end
      end

      def next_free_uid(starting_from = 4000)
        candidate = starting_from
        existing_uids = @@allocated_uids
        node["etc"]["passwd"].each do |_username, entry|
          existing_uids << entry["uid"] unless existing_uids.include?(entry["uid"])
        end
        candidate += 1 while existing_uids.include?(candidate)
        @@allocated_uids << candidate
        candidate
      end
    end
  end
end

class Chef::Recipe
  include AWS::OpsWorks::User
end
class Chef::Resource::User
  include AWS::OpsWorks::User
end
