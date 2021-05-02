resource "aws_ecr_repository" "this" {
  name = var.ecr_repository_name

  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_ecr_repository_policy" "ecr_policy" {
  repository = aws_ecr_repository.this.name

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": " CodeBuildAccess",
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"
      ]
    }
  ]
}
EOF
}