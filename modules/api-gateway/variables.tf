variable "lambda_integration_invoke_arn" { type = string }
variable "lambda_function_name" { type = string }
variable "api_gateway_name" {
  description = "The name of the API Gateway"
  type        = string
  default     = "statement-analysis-api"
}