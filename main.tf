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
    use_lockfile = "terraform-state-lock"
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
