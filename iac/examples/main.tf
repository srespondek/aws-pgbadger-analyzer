locals {
  vpc_id = "vpc-xxxxxxxxx"

  subnet_tag_names = [
      "private-1-prod",
      "private-0-prod"
  ]

  code_build_builder_stack_name = "aws-pgbadger-analyzer-builder-${var.environment}"

  ecr_repository_name = "aws-pgbadger-analyzer-${var.environment}"
  ecr_image_version = "1.0.0"

  debug_mode = "False"

}


module "storage" {
  source = "git@github.com:srespondek/aws-pgbadger-analyzer.git//iac/storage?ref=v1.0.0"
  bucket_name = "aws-pgbadger-analyzer-reports-${var.environment}"
  region = var.region
}

module "iam" {
  source  = "git@github.com:srespondek/aws-pgbadger-analyzer.git//iac/iam?ref=v1.0.0"

  region = var.region
  vpc_id = local.vpc_id
  subnet_tag_names = local.subnet_tag_names

  code_build_reporters_access_prefix = "aws-pgbadger-analyzer-executor"
  code_build_builder_stack_name = local.code_build_builder_stack_name

  ecr_repository_name = local.ecr_repository_name

  bucket_name = "aws-pgbadger-analyzer-reports-${var.environment}"
  bucket_arn = module.storage.bucket_arn
}

module "repo" {
  source  = "git@github.com:srespondek/aws-pgbadger-analyzer.git//iac/repo?ref=v1.0.0"

  ecr_repository_name = local.ecr_repository_name
  region = var.region

}

module "builder" {
  source  = "git@github.com:srespondek/aws-pgbadger-analyzer.git//iac/builder?ref=v1.0.0"

  region = var.region
  vpc_id = local.vpc_id
  code_build_stack_name = local.code_build_builder_stack_name
  subnets_id_list = module.iam.subnets_id

  ecr_repository_url = module.repo.ecr_repository_url
  ecr_image_version = local.ecr_image_version
  ecr_repository_name = local.ecr_repository_name

  iam_role_arn = module.iam.iam_role_arn

}

module "executor_tenant_a" {
  source  = "git@github.com:srespondek/aws-pgbadger-analyzer.git//iac/executor?ref=v1.0.0"


  tenant = "a"
  code_build_stack_name = "aws-pgbadger-executor-${var.environment}"
  db_name = "rds-test-instance-name-a"

  region = var.region
  iam_role_arn = module.iam.iam_role_arn
  ecr_image_version = local.ecr_image_version
  ecr_repository_url = module.repo.ecr_repository_url
  environment = var.environment
  db_region = var.region
  bucket_name = "aws-pgbadger-analyzer-reports-${var.environment}"
  debug_mode = local.debug_mode
  security_group_id = module.builder.sg_id
  subnets_id_list = module.iam.subnets_id
  vpc_id = local.vpc_id
}

module "executor_tenant_b" {
  source  = "git@github.com:srespondek/aws-pgbadger-analyzer.git//iac/executor?ref=v1.0.0"

  tenant = "b"
  code_build_stack_name = "aws-pgbadger-executor-${var.environment}"
  db_name = "rds-test-instance-name-b"

  region = var.region
  iam_role_arn = module.iam.iam_role_arn
  ecr_image_version = local.ecr_image_version
  ecr_repository_url = module.repo.ecr_repository_url
  environment = var.environment
  db_region = var.region
  bucket_name = "aws-pgbadger-analyzer-reports-${var.environment}"
  debug_mode = local.debug_mode
  security_group_id = module.builder.sg_id
  subnets_id_list = module.iam.subnets_id
  vpc_id = local.vpc_id
}
