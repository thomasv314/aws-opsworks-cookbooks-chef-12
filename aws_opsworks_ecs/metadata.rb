name        "aws_opsworks_ecs"
description "Support for ECS"
maintainer  "AWS OpsWorks"
license     "Apache 2.0"
version     "1.0.0"

depends "aws_opsworks_helpers"

recipe "aws_opsworks_ecs::setup", "Install Amazon ECS agent."
recipe "aws_opsworks_ecs::shutdown", "Remove Amazon ECS agent and docker."
recipe "aws_opsworks_ecs::cleanup", "Remove Amazon ECS agent and docker."
recipe "aws_opsworks_ecs::deploy", "not implemented"
recipe "aws_opsworks_ecs::undeploy", "not implemented"
recipe "aws_opsworks_ecs::configure", "not implemented"
