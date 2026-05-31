resource "aws_s3_bucket" "statement_analysis_docs" {
  bucket = "statement-analysis-docs"
  provider = aws.textract-region
}
