variable "aws_profile" {
  type        = string
  description = "AWS profile"
  default     = "main-dev"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "eu-central-1"
}

variable "aws_account_name" {
  type        = string
  description = "AWS account"
}

variable "aws_env" {
  type        = string
  description = "AWS environment"
}
