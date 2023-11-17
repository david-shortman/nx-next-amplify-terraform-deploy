variable "github_token" {}

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

resource "aws_amplify_app" "test_app" {
  name       = "test_app"
  repository = "https://github.com/david-shortman/nx-next-amplify-terraform-deploy"
  access_token = var.github_token

  build_spec = <<-EOT
    version: 1
    applications:
      - appRoot: apps/test-app
      frontend:
        phases:
          preBuild:
            commands:
              - npm ci
          build:
            commands:
              - nx run test-app:build:production
        artifacts:
          baseDirectory: dist/test-app
          files:
            - '**/*'
        cache:
          paths:
            - node_modules/**/*
  EOT

  # The default rewrites and redirects added by the Amplify Console.
  custom_rule {
    source = "/<*>"
    status = "404"
    target = "/index.html"
  }
}

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.test_app.id
  branch_name = "main"

  stage     = "PRODUCTION"
}
