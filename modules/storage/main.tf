resource "aws_s3_bucket" "statement_analysis_docs" {
  bucket   = var.bucket_name
  provider = aws.textract-region
}

resource "aws_s3_bucket_policy" "statement_analysis_textract_read" {
  bucket = aws_s3_bucket.statement_analysis_docs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "TextractReadAccess"
      Effect    = "Allow"
      Principal = { Service = "textract.amazonaws.com" }
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.statement_analysis_docs.arn}/*"
    }]
  })
}
