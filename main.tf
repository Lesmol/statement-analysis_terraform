terraform {
  required_version = ">= 1.10"

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
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "statement-analysis"
      ManagedBy   = "terraform"
      Environment = "prod"
    }
  }
}

provider "aws" {
  alias  = "textract-region"
  region = "eu-west-1"
}
