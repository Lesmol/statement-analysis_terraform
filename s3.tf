resource "aws_s3_bucket" "statement_analysis_logs" {
  bucket = "statement-analysis-logs"
}

resource "aws_s3_bucket_public_access_block" "statement_analysis_logs" {
  bucket = aws_s3_bucket.statement_analysis_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "statement_analysis_logs" {
  bucket = aws_s3_bucket.statement_analysis_logs.id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    expiration {
      days = 180
    }
  }
}

resource "aws_s3_bucket" "statement_analysis_statements" {
  bucket = "statement-analysis-statements"
}

resource "aws_s3_bucket_versioning" "statement_analysis_statements" {
  bucket = aws_s3_bucket.statement_analysis_statements.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "statement_analysis_statements" {
  bucket = aws_s3_bucket.statement_analysis_statements.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_logging" "statement_analysis_statements" {
  bucket        = aws_s3_bucket.statement_analysis_statements.id
  target_bucket = aws_s3_bucket.statement_analysis_logs.id
  target_prefix = "s3-access-logs/"
}

resource "aws_s3_bucket_public_access_block" "statement_analysis_statements" {
  bucket = aws_s3_bucket.statement_analysis_statements.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle rule: transition to S3 Intelligent-Tiering after 90 days
resource "aws_s3_bucket_lifecycle_configuration" "statement_analysis_statements" {
  bucket = aws_s3_bucket.statement_analysis_statements.id

  rule {
    id     = "transition-to-intelligent-tiering"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "INTELLIGENT_TIERING"
    }
  }

  rule {
    id     = "abort-incomplete-multipart"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}