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
  description = "Comma-separated list of allowed CORS origins"
  type        = string
}
