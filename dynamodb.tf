locals {
  project_tag = "statement-analysis"
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

# Table 1: Banks
resource "aws_dynamodb_table" "statement_analysis_banks" {
  name           = "statement_analysis_banks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "bankId"

  attribute {
    name = "bankId"
    type = "S"
  }

}

# Table 2: Users (registered user profiles)
resource "aws_dynamodb_table" "statement_analysis_users" {
  name           = "statement_analysis_users"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "userId"

  attribute {
    name = "userId"
    type = "S"
  }

}

# Table 3: Accounts (bank accounts belonging to a user)
resource "aws_dynamodb_table" "statement_analysis_accounts" {
  name           = "statement_analysis_accounts"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "accountId"
  range_key      = "userId"

  attribute {
    name = "accountId"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "bankId"
    type = "S"
  }

  global_secondary_index {
    name = "bankId-index"
    projection_type = "ALL"
    hash_key = "bankId"
  }

}

# Table 4: Statement uploads (metadata and S3 pointer)
resource "aws_dynamodb_table" "statement_analysis_statement_uploads" {
  name           = "statement_analysis_statement_uploads"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "uploadId"

  attribute {
    name = "uploadId"
    type = "S"
  }

  attribute {
    name = "accountId"
    type = "S"
  }

  global_secondary_index {
    name            = "accountId-index"
    projection_type = "ALL"
    hash_key       = "accountId"
  }

}