
resource "aws_codebuild_project" "this" {
  name = var.code_build_stack_name
  service_role = var.iam_role_arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_LARGE"
    image = "${var.ecr_repository_url}:${var.ecr_image_version}"
    type = "LINUX_CONTAINER"

    environment_variable {
      name = "ENVIRONMENT"
      value = var.environment
    }

    environment_variable {
      name = "TENANT"
      value = var.tenant
    }

    environment_variable {
      name = "DB_NAME"
      value = var.db_name
    }

    environment_variable {
      name = "DB_REGION"
      value = var.db_region
    }

    environment_variable {
      name = "BUCKET_NAME"
      value = var.bucket_name
    }

    environment_variable {
      name = "DEBUG_MODE"
      value = var.debug_mode
    }
  }

  source {
    type = "NO_SOURCE"
    buildspec = <<EOF
version: 0.2

phases:
  build:
    commands:
       - python3 /opt/download_logs.py
       - cd /data/error; pgbadger -f stderr -J 8 postgresql.log.*
       - python3 /opt/upload_report.py
EOF

  }

  vpc_config {
    security_group_ids = [
      var.security_group_id]
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
