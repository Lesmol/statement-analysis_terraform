resource "aws_iam_role" "textract_sns_role" {
  name = "TextractSNSPublishRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = { Service = "textract.amazonaws.com" }
      }
    ]
  })
}

resource "aws_iam_role_policy" "textract_sns_publish_policy" {
  name = "TextractSNSPublishPolicy"
  role = aws_iam_role.textract_sns_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = aws_sns_topic.statement_analysis_textract_completion_topic.arn
      }
    ]
  })
}