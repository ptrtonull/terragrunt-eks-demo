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
}


dependency "aws-common" {
  config_path = "../aws-common"
}

inputs = {
  azs = dependency.aws-common.outputs.aws_availability_zones.names
  name = local.name
  cidr = "10.0.0.0/16"
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true
  private_subnet_tags = {
    "kubernetes.io/cluster/${local.name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    Example = local.name
  }
}
