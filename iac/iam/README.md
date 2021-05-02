## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.62.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| bucket\_arn | S3 bucket arn | `string` | n/a | yes |
| bucket\_name | S3 Bucket name | `string` | n/a | yes |
| code\_build\_builder\_stack\_name | CodeBuild stack name | `string` | n/a | yes |
| code\_build\_reporters\_access\_prefix | CodeBuild Reporters Prefix names | `string` | n/a | yes |
| ecr\_repository\_name | Repository name | `string` | n/a | yes |
| region | Region name | `string` | n/a | yes |
| subnet\_tag\_names | List with subnets TAGs | `list(string)` | n/a | yes |
| vpc\_id | VPC id | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| iam\_role\_arn | n/a |
| subnets\_id | n/a |

