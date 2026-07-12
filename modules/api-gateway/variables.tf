variable "lambda_integration_invoke_arn" { type = string }
variable "lambda_function_name" { type = string }
variable "cognito_user_pool_id" { type = string }
variable "cognito_client_id" { type = string }
variable "api_gateway_name" {
  description = "The name of the API Gateway"
  type        = string
  default     = "statement-analysis-api"
}
variable "cors_allowed_origins" {
  description = "Comma-separated list of allowed CORS origins known at API creation time (must not depend on the Amplify app's default_domain, or it forms a cycle with module.amplify)"
  type        = string
}

variable "amplify_domain" {
  description = "Amplify app's default_domain, added to CORS allow_origins out-of-band after creation to avoid a cycle with module.amplify (which needs this API's gateway_url)"
  type        = string
}
