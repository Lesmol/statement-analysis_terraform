resource "aws_s3_bucket" "statement_analysis_docs" {
  bucket   = var.bucket_name
  provider = aws.textract-region
}

data "aws_iam_policy_document" "textract_read" {
  statement {
    sid     = "TextractReadAccess"
    actions = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.statement_analysis_docs.arn}/*"]
    principals {
      type        = "Service"
      identifiers = ["textract.amazonaws.com"]
    }
  }
}

resource "aws_s3_bucket_policy" "statement_analysis_textract_read" {
  bucket = aws_s3_bucket.statement_analysis_docs.id
  policy = data.aws_iam_policy_document.textract_read.json
}
