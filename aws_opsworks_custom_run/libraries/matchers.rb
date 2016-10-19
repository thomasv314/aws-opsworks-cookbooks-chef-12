if defined?(ChefSpec)
  def prepare_opsworks_custom_run(command_id)
    ChefSpec::Matchers::ResourceMatcher.new(:aws_opsworks_custom_run, :prepare, command_id)
  end
end
