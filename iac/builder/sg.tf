module "sg" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-security-group.git//?ref=v3.18.0"

  name = "${var.code_build_stack_name}-sg"

  description = "Security group for example usage with aws-pgbadger-analyzer"
  vpc_id = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["all-all"]

  egress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules       = ["all-all"]

}