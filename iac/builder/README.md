## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.62.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| code\_build\_stack\_name | Stack name | `string` | n/a | yes |
| ecr\_image\_version | ECR Image version | `string` | n/a | yes |
| ecr\_repository\_name | ECR image name | `string` | n/a | yes |
| ecr\_repository\_url | ECR repo url | `string` | n/a | yes |
| iam\_role\_arn | IAM role ARN | `string` | n/a | yes |
| region | Region name | `string` | n/a | yes |
| subnets\_id\_list | List of Subnet ID | `list(string)` | n/a | yes |
| vpc\_id | VPC id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| sg\_id | n/a |

