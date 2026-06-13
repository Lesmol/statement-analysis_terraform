resource "aws_s3_bucket" "statement_analysis_docs" {
  bucket = var.bucket_name
  provider = aws.textract-region
}
