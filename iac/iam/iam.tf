data "aws_subnet_ids" "this" {
  vpc_id = var.vpc_id

  filter {
    name = "tag:Name"
    values = var.subnet_tag_names
  }
}

data "aws_caller_identity" "account_id" {}


data "aws_subnet" "this" {
  for_each = data.aws_subnet_ids.this.ids
  id = each.value
}

resource "aws_iam_role" "this" {
  name = "aws-pgbadger-analyzer-${var.region}-reports-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "this" {
  role = aws_iam_role.this.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement":
  [
    {
      "Effect": "Allow",
      "Resource": [
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.account_id.account_id}:log-group:/aws/codebuild/${var.code_build_reporters_access_prefix}",
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.account_id.account_id}:log-group:/aws/codebuild/${var.code_build_reporters_access_prefix}-*:*"
      ],
      "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Resource": [
          "${var.bucket_arn}",
          "${var.bucket_arn}/*"
      ],
      "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
          "codebuild:CreateReportGroup",
          "codebuild:CreateReport",
          "codebuild:UpdateReport",
          "codebuild:BatchPutTestCases",
          "codebuild:BatchPutCodeCoverages"
      ],
      "Resource": [
          "arn:aws:codebuild:${var.region}:${data.aws_caller_identity.account_id.account_id}:report-group/${var.code_build_reporters_access_prefix}",
          "arn:aws:codebuild:${var.region}:${data.aws_caller_identity.account_id.account_id}:report-group/${var.code_build_reporters_access_prefix}-*",
          "arn:aws:codebuild:${var.region}:${data.aws_caller_identity.account_id.account_id}:report-group/${var.code_build_builder_stack_name}",
          "arn:aws:codebuild:${var.region}:${data.aws_caller_identity.account_id.account_id}:report-group/${var.code_build_builder_stack_name}-*"

      ]
    },
    {
      "Effect": "Allow",
      "Resource": [
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.account_id.account_id}:log-group:/${var.code_build_reporters_access_prefix}/",
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.account_id.account_id}:log-group:/${var.code_build_reporters_access_prefix}-*/*",
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.account_id.account_id}:log-group:/${var.code_build_builder_stack_name}/",
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.account_id.account_id}:log-group:/${var.code_build_builder_stack_name}/*"

      ],
      "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeDhcpOptions",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
          "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": "arn:aws:ec2:${var.region}:${data.aws_caller_identity.account_id.account_id}:network-interface/*"
    },
    {
      "Effect": "Allow",
      "Action": "rds:*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "ecr:GetAuthorizationToken",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
          "ecr:CompleteLayerUpload",
          "ecr:TagResource",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage"
      ],
      "Resource": "arn:aws:ecr:${var.region}:${data.aws_caller_identity.account_id.account_id}:repository/${var.ecr_repository_name}"
    }
  ]
}
EOF
}
