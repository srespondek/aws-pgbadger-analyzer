variable "region" {
  type = string
  description = "AWS region"
  default = "eu-central-1"
}

variable "environment" {
  type = string
  description = "AWS environment"
  default = "dev"
}
