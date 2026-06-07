resource "aws_iam_role" "lambda_exec" {
  name = "statement_analysis_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
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
      }
    ]
  })
}

resource "aws_lambda_function" "statement_analysis_function" {
  function_name = "statement-analysis-function"
  package_type = "Image"
  image_uri    = "${aws_ecr_repository.statement_analysis_repository.repository_url}:latest"
  role          = aws_iam_role.lambda_exec.arn
  memory_size = 2048
  timeout       = 300

  environment {
    variables = {
      AWS_S3_BUCKET_NAME = aws_s3_bucket.statement_analysis_docs.bucket
      AWS_REGION = provider.aws.textract-region.region
    }
  }
}