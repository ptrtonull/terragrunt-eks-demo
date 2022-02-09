locals {
  root_deployments_dir = get_parent_terragrunt_dir()
  relative_module_path  = path_relative_to_include()
  module_hierarchy_levels = compact(split("/", local.relative_module_path))
  module = basename(get_terragrunt_dir())

  possible_config_dirs = [
    for i in range(0, length(local.module_hierarchy_levels) + 1) :
    join("/", concat(
      [local.root_deployments_dir],
      slice(local.module_hierarchy_levels, 0, i)
    ))
  ]

  possible_config_paths = flatten([
    for dir in local.possible_config_dirs : [
      "${dir}/data/common.yaml",
      "${dir}/data/${local.module}.yaml"
    ]
  ])

  # Load every YAML config file that exists into an HCL object
  file_configs = [ for path in local.possible_config_paths : yamldecode(file(path)) if fileexists(path) ]

  # Merge the objects together, with deeper configs overriding higher configs
  merged_config = merge(local.file_configs...)

  project_name = local.merged_config.project_name
  aws_env = local.merged_config.aws_env
  aws_region = local.merged_config.aws_region
  aws_profile = local.merged_config.aws_profile
  aws_account_name = local.merged_config.aws_account_name
  aws_account_id = local.merged_config.aws_account_id

  # TF module sources
  tf_module = local.module
  tf_component = local.merged_config.component
  tf_modules = local.merged_config.tf_modules
}

remote_state {
  backend = "s3"
  config = {
    encrypt = true
    bucket = "terragrunt-${local.project_name}-s3"
    key = "${path_relative_to_include()}/terraform.tfstate"
    region = local.aws_region
    profile = local.aws_profile
    dynamodb_table = "terragrunt-${local.project_name}-ddb-${local.aws_account_name}"
  }

  generate = {
    path = "backend.tf"
    if_exists = "overwrite"
  }
}
