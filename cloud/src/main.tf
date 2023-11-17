variable "github_token" {}

resource "aws_amplify_app" "test_app" {
  name       = "test_app"
  repository = "https://github.com/david-shortman/nx-next-amplify-terraform-deploy"
  access_token = var.github_token

  build_spec = <<-EOT
    version: 0.1
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

  environment_variables = {
    ENV = "test"
  }
}
