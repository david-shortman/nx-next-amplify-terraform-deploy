variable "GITHUB_TOKEN" {}
variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}

terraform {
  cloud {
    organization = "example-org-1c9e17"

    workspaces {
      name = "test-app"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

resource "aws_amplify_app" "test_app" {
  name       = "test_app"
  repository = "https://github.com/david-shortman/nx-next-amplify-terraform-deploy"
  access_token = var.GITHUB_TOKEN

  environment_variables = {
    AMPLIFY_MONOREPO_APP_ROOT = "test-app"
  }

  build_spec = <<-EOT
    version: 1
    applications:
      - appRoot: test-app
        frontend:
          phases:
            build:
              commands:
                - cd ../
                - npm ci
                - npx nx run test-app:build:production
          artifacts:
            baseDirectory: ../dist/test-app/.next
            files:
              - '**/*'
          cache:
            paths:
              - node_modules/**/*
  EOT

  platform = "WEB_COMPUTE"

  # The default rewrites and redirects added by the Amplify Console.
#  custom_rule {
#    source = "/<*>"
#    status = "404"
#    target = "/"
#  }
}

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.test_app.id
  branch_name = "main"
  enable_auto_build = false

  stage     = "PRODUCTION"
}

resource "aws_amplify_webhook" "main" {
  app_id      = aws_amplify_app.test_app.id
  branch_name = aws_amplify_branch.main.branch_name
  description = "triggermain"
}
