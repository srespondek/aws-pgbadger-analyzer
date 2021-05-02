data "aws_caller_identity" "account_id" {}

resource "aws_iam_role" "trigger" {
  name = "${var.code_build_stack_name}-trigger-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "trigger" {
  role = aws_iam_role.trigger.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "codebuild:StartBuild"
            ],
            "Resource": [
                "arn:aws:codebuild:${var.region}:${data.aws_caller_identity.account_id.account_id}:project/${var.code_build_stack_name}"
            ]
        }
    ]
}
EOF
}


resource "aws_cloudwatch_event_rule" "this" {
  name = "codebuild-pgbadger-trigger"
  description = "Trigger for CodeBuild service"

  schedule_expression = "cron(0 22 ? * 1 *)"

  is_enabled = "true"
}

resource "aws_cloudwatch_event_target" "this" {
  rule      = aws_cloudwatch_event_rule.this.name
  arn       = aws_codebuild_project.this.arn
  role_arn = aws_iam_role.trigger.arn
}
