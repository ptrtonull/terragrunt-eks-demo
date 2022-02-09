include "root" {
  path = find_in_parent_folders()
  merge_strategy = "deep"
  expose = true
}

terraform {
  source = "../../../../../..//helper-modules/aws-common-data"
}

inputs = {
  project_name = include.root.locals.project_name
  aws_account_name = include.root.locals.aws_account_name
  aws_env = include.root.locals.aws_env
  aws_profile = include.root.locals.aws_profile
  aws_region = include.root.locals.aws_region
}
