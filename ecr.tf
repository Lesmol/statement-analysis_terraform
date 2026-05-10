data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "statement_analysis" {
  name = "statement-analysis"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "statement_analysis" {
  repository = aws_ecr_repository.statement_analysis.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LambdaECRAccess"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Condition = {
          StringLike = {
            "aws:sourceArn" = "arn:aws:lambda:*:${data.aws_caller_identity.current.account_id}:function:*"
          }
        }
      }
    ]
  })
}
