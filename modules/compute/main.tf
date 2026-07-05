locals {
  aws_region = "eu-west-1"
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${var.s3_bucket_name}/*"]
  }

  statement {
    actions   = ["textract:StartDocumentAnalysis", "textract:StartDocumentTextDetection"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "statement_analysis_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy" "lambda_policy" {
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

resource "aws_lambda_function" "statement_analysis_function" {
  function_name = var.statement_analysis_function_name
  package_type  = "Image"
  image_uri     = "${var.ecr_repository_url}:latest"
  role          = aws_iam_role.lambda_exec.arn
  memory_size   = 2048
  timeout       = 300

  environment {
    variables = {
      AWS_S3_BUCKET_NAME           = var.s3_bucket_name
      TEXTRACT_AWS_REGION          = local.aws_region
      AWS_LWA_READINESS_CHECK_PATH = "/actuator/health"
      AWS_LWA_PORT                 = "8080"
      COGNITO_USER_POOL_ID         = var.cognito_user_pool_id
      COGNITO_CLIENT_ID            = var.cognito_client_id
      COGNITO_CLIENT_SECRET        = var.cognito_client_secret
      AWS_SNS_TOPIC                = var.sns_topic
      AWS_SNS_ROLE                 = var.sns_role
    }
  }

  lifecycle {
    ignore_changes = [image_uri]
  }
}
