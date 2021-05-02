## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.62.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| bucket\_name | S3 Bucket name | `string` | n/a | yes |
| code\_build\_stack\_name | Code Build project name | `string` | n/a | yes |
| db\_name | RDS DB name | `string` | n/a | yes |
| db\_region | RDS DB region | `string` | n/a | yes |
| debug\_mode | Debug mode | `string` | n/a | yes |
| ecr\_image\_version | ECR Image version | `string` | n/a | yes |
| ecr\_repository\_url | ECR repo url | `string` | n/a | yes |
| environment | AWS environment | `string` | `"dev"` | no |
| iam\_role\_arn | IAM role ARN | `string` | n/a | yes |
| region | Region name | `string` | n/a | yes |
| security\_group\_id | Security group id | `string` | n/a | yes |
| subnets\_id\_list | List of Subnet ID | `list(string)` | n/a | yes |
| tenant | Tenant name | `string` | n/a | yes |
| vpc\_id | VPC id | `string` | n/a | yes |

## Outputs

No output.

