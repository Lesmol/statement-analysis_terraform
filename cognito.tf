resource "aws_cognito_user_pool" "statement_analysis_user_pool" {
  name = "statement_analysis_user_pool"

  username_attributes = ["email"]

  auto_verified_attributes = ["email"]

  email_verification_message = "Your verification code is {####}"
  email_verification_subject = "Verify your email for Statement Analysis"

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }

  mfa_configuration = "OPTIONAL"

  software_token_mfa_configuration {
    enabled = true
  }

  account_recovery_setting {
    recovery_mechanism {
      name       = "verified_email"
      priority   = 1
    }
  }

  schema {
    name              = "email"
    attribute_data_type = "String"
    required          = true
    mutable           = true
  }

  schema {
    name              = "name"
    attribute_data_type = "String"
    required          = false
    mutable           = true
  }

  tags = {
    Project = "statement-analysis"
  }
}

resource "aws_cognito_user_pool_client" "statement_analysis_app_client" {
  name                = "statement_analysis_app_client"
  user_pool_id        = aws_cognito_user_pool.statement_analysis_user_pool.id

  generate_secret = false

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  read_attributes = ["email", "name"]

  access_token_validity  = 1
  id_token_validity      = 1
  refresh_token_validity = 30
  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  prevent_user_existence_errors = "ENABLED"
}

resource "aws_cognito_user_pool_domain" "statement_analysis_domain" {
  domain       = var.cognito_domain_prefix
  user_pool_id = aws_cognito_user_pool.statement_analysis_user_pool.id
}

resource "aws_cognito_user_group" "statement_analysis_admins" {
  name        = "statement_analysis_admins"
  user_pool_id = aws_cognito_user_pool.statement_analysis_user_pool.id
  description = "Administrators with access to /api/v1/admin/** endpoints"
}