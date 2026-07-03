resource "aws_cognito_user_pool" "statement_analysis" {
  name = var.user_pool_name

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
  }

  auto_verified_attributes = ["email"]

  schema {
    name                = "email"
    attribute_data_type = "String"
    required            = true
    mutable             = true
  }

  schema {
    name                = "phone_number"
    attribute_data_type = "String"
    required            = false
    mutable             = true
  }

  lifecycle {
    ignore_changes  = [schema]
    prevent_destroy = true
  }
}

resource "aws_cognito_user_pool_client" "statement_analysis" {
  name         = var.user_pool_client_name
  user_pool_id = aws_cognito_user_pool.statement_analysis.id

  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  token_validity_units {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }

  access_token_validity  = 1
  id_token_validity      = 1
  refresh_token_validity = 30

  generate_secret = true
}
