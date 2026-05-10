resource "aws_iam_policy" "statement_analysis_app_policy" {
  name        = "statement_analysis_app_policy"
  description = "Policy for Spring Boot application to access DynamoDB and S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.statement_analysis_banks.arn,
          "${aws_dynamodb_table.statement_analysis_banks.arn}/index/*",
          aws_dynamodb_table.statement_analysis_users.arn,
          "${aws_dynamodb_table.statement_analysis_users.arn}/index/*",
          aws_dynamodb_table.statement_analysis_accounts.arn,
          "${aws_dynamodb_table.statement_analysis_accounts.arn}/index/*",
          aws_dynamodb_table.statement_analysis_statement_uploads.arn,
          "${aws_dynamodb_table.statement_analysis_statement_uploads.arn}/index/*"
        ]
      },
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.statement_analysis_statements.arn}/*"
      },
      {
        Sid    = "ECRAuthAccess"
        Effect = "Allow"
        Action = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Sid    = "ECRImageAccess"
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = aws_ecr_repository.statement_analysis.arn
      }
    ]
  })
}

resource "aws_iam_role" "statement_analysis_app_role" {
  name               = "statement_analysis_app_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "statement_analysis_role" {
  name = "statement_analysis_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "statement_analysis_lambda_basic_execution" {
  role       = aws_iam_role.statement_analysis_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "statement_analysis_lambda_app_policy" {
  role       = aws_iam_role.statement_analysis_role.name
  policy_arn = aws_iam_policy.statement_analysis_app_policy.arn
}

resource "aws_iam_role_policy_attachment" "statement_analysis_app_role_attachment" {
  role       = aws_iam_role.statement_analysis_app_role.name
  policy_arn = aws_iam_policy.statement_analysis_app_policy.arn
}