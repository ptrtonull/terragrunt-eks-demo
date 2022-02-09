include "root" {
  path = find_in_parent_folders()
  expose = true
  merge_strategy = "deep"
}

terraform {
  source = local.tf_source
}

locals {
  tf_module = include.root.locals.module
  tf_component = include.root.locals.tf_component
  tf_source = include.root.locals.merged_config.tf_modules["${local.tf_component}-${local.tf_module}"]["source"]
  name = "eks-demo"
  cluster_version = "1.21"
}

generate "provider-local" {
  path = "provider-local.tf"
  if_exists = "overwrite"
  contents = file("../../../../../../provider-config/eks_cluster/eks_cluster.tf")
}

generate "vriables-local" {
  path = "variables-local.tf"
  if_exists = "overwrite"
  contents = <<EOF
variable aws_profile {}
variable aws_region {}
EOF
}


dependency "vpc" {
  config_path = "../vpc"
}

dependencies {
  paths = ["../aws-common", "../vpc"]
}

inputs = {
  aws_profile = include.root.locals.aws_profile
  aws_region = include.root.locals.aws_region
  cluster_name                    = local.name
  cluster_version                 = local.cluster_version
  vpc_id                          = dependency.vpc.outputs.vpc_id
  subnets                         = dependency.vpc.outputs.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  worker_groups_launch_template = include.root.locals.merged_config.worker_groups_launch_template

  tags = {
    Example    = local.name
  }
}
