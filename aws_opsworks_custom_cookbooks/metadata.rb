name        "aws_opsworks_custom_cookbooks"
description "Supports custom user cookbooks"
maintainer  "AWS OpsWorks"
license     "Apache 2.0"
version     "1.0.0"

recipe "aws_opsworks_custom_cookbooks::checkout", "Checkout custom Cookbooks"
recipe "aws_opsworks_custom_cookbooks::create_or_delete", "Will only create or delete existing cookbooks"

depends "s3_file"

attribute "aws_opsworks_custom_cookbooks/repository",
  :display_name => "URL to you Chef cookbooks",
  :description => "URL to you Chef cookbooks",
  :required => true,
  :type => 'string'
