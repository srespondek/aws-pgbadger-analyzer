variable "region" {
  type = string
  description = "Region name"
}

variable "vpc_id" {
  type = string
  description = "VPC id"
}

variable "code_build_stack_name" {
  type = string
  description = "Stack name"
}

variable "subnets_id_list" {
  type = list(string)
  description = "List of Subnet ID"
}

variable "ecr_repository_url" {
  type = string
  description = "ECR repo url"
}

variable "ecr_image_version" {
  type = string
  description = "ECR Image version"
}

variable "ecr_repository_name" {
  type = string
  description = "ECR image name"
}

variable "iam_role_arn" {
  type = string
  description = "IAM role ARN"
}