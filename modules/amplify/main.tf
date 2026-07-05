data "aws_iam_policy_document" "amplify_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["amplify.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "amplify" {
  name               = "statement-analysis-amplify-role"
  assume_role_policy = data.aws_iam_policy_document.amplify_assume_role.json
}

resource "aws_iam_role_policy_attachment" "amplify" {
  role       = aws_iam_role.amplify.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-Amplify"
}

resource "aws_amplify_app" "statement_analysis" {
  name       = var.app_name
  repository = var.repository_url

  iam_service_role_arn = aws_iam_role.amplify.arn
  access_token         = var.github_access_token

  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - npm i
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: build
        files:
          - '**/*'
      cache:
        paths:
          - node_modules/**/*
  EOT

  custom_rule {
    source = "/<*>"
    status = "404-200"
    target = "/index.html"
  }

  environment_variables = {
    REACT_APP_API_URL = var.api_gateway_url
  }
}

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.statement_analysis.id
  branch_name = var.branch_name

  stage = "PRODUCTION"

  enable_auto_build = true
}
