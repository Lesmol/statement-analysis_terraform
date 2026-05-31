resource "aws_s3_bucket" "statement_analysis_docs" {
  bucket = "statement-analysis-documents"
  provider = aws.textract-region
}
