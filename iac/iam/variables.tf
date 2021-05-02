variable "region" {
  type = string
  description = "Region name"
}

variable "vpc_id" {
  type = string
  description = "VPC id"
}

variable "subnet_tag_names" {
  type = list(string)
  description = "List with subnets TAGs"
}

variable "code_build_reporters_access_prefix" {
  type = string
  description = "CodeBuild Reporters Prefix names"
}

variable "code_build_builder_stack_name" {
  type = string
  description = "CodeBuild stack name"
}

variable "ecr_repository_name" {
  type = string
  description = "Repository name"
}

variable "bucket_name" {
  type = string
  description = "S3 Bucket name"
}

variable "bucket_arn" {
  type = string
  description = "S3 bucket arn"
}