actions :prepare
default_action :prepare

attribute :command_id, :kind_of => String, :name_attribute => true, :required => true
attribute :base_dir, :kind_of => String, :required => true
attribute :cookbook_path, :kind_of => Array, :required => true
