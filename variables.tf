variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name for statement analysis"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "af-south-1"
}