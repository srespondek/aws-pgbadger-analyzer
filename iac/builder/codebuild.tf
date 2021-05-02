data "aws_caller_identity" "account_id" {}

resource "aws_codebuild_project" "builder" {
  name = var.code_build_stack_name
  service_role = var.iam_role_arn


  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_MEDIUM"
    image = "aws/codebuild/standard:5.0-21.04.23"
    type = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name = "DOCKER_IMAGE_NAME"
      value = var.ecr_repository_name
    }

    environment_variable {
      name = "DOCKER_IMAGE_VERSION"
      value = var.ecr_image_version
    }

    environment_variable {
      name = "ECR_REPOSITORY_URL"
      value = var.ecr_repository_url
    }
    environment_variable {
      name = "REGION"
      value = var.region
    }
    environment_variable {
      name = "ACCOUNT_ID"
      value = data.aws_caller_identity.account_id.account_id
    }


  }

  source {
    type = "GITHUB"
    location = "https://github.com/chaosgears/aws-pgbadger-analyzer.git"
    buildspec = <<EOF
version: 0.2

phases:
  build:
    commands:
       - aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
       - docker build -t $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_VERSION .
       - docker tag $DOCKER_IMAGE_NAME:$DOCKER_IMAGE_VERSION $ECR_REPOSITORY_URL:$DOCKER_IMAGE_VERSION
       - docker push $ECR_REPOSITORY_URL:$DOCKER_IMAGE_VERSION
EOF
}

  vpc_config {
    security_group_ids = [
      module.sg.this_security_group_id]
    subnets = var.subnets_id_list
    vpc_id = var.vpc_id
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/${var.code_build_stack_name}/"
      stream_name = "pgbadger"
    }
  }

}