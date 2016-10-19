name        "aws_opsworks_agent"
description "Installs/Configures aws_opsworks_agent"
maintainer  "AWS OpsWorks"
license     "Apache 2.0"
version     "0.1.0"

depends "aws_opsworks_helpers"
depends "aws_opsworks_agent_version"
depends "aws_opsworks_ebs"
depends "aws_opsworks_users"
depends "aws_opsworks_system"
depends "aws_opsworks_custom_cookbooks"
depends "aws_opsworks_custom_run"
depends "aws_opsworks_ecs"
