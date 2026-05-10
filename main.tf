terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
  }

  backend "s3" {
    bucket         = "statement-analysis-terraform-state"
    key            = "statements/terraform.tfstate"
    region         = "af-south-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "statement-analysis"
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}

check "s3_bucket_not_public" {
  data "aws_s3_bucket_policy_status" "statements" {
    bucket = aws_s3_bucket.statement_analysis_statements.id
  }

  assert {
    condition     = !data.aws_s3_bucket_policy_status.statements.policy_status[0].is_public
    error_message = "S3 statements bucket has become publicly accessible!"
  }
}
