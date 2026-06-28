locals {
  aws_region = "eu-west-1"
}

resource "aws_iam_role" "lambda_exec" {
  name = "statement_analysis_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_exec.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action   = ["s3:GetObject", "s3:PutObject"]
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${var.s3_bucket_name}/*"
      },
      {
        Action   = ["textract:StartDocumentAnalysis", "textract:StartDocumentTextDetection"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
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
    }
  }

  lifecycle {
    ignore_changes = [image_uri]
  }
}
