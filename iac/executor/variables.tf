variable "region" {
  type = string
  description = "Region name"
}

variable "code_build_stack_name" {
  type = string
  description = "Code Build project name"
}

variable "iam_role_arn" {
  type = string
  description = "IAM role ARN"
}

variable "ecr_image_version" {
  type = string
  description = "ECR Image version"
}

variable "ecr_repository_url" {
  type = string
  description = "ECR repo url"
}

variable "environment" {
  type = string
  description = "AWS environment"
  default = "dev"
}

variable "tenant" {
  type = string
  description = "Tenant name"
}

variable "db_name" {
  type = string
  description = "RDS DB name"
}

variable "db_region" {
  type = string
  description = "RDS DB region"
}

variable "bucket_name" {
  type = string
  description = "S3 Bucket name"
}

variable "debug_mode" {
  type = string
  description = "Debug mode"
}

variable "security_group_id" {
  type = string
  description = "Security group id"
}

variable "subnets_id_list" {
  type = list(string)
  description = "List of Subnet ID"
}

variable "vpc_id" {
  type = string
  description = "VPC id"
}
