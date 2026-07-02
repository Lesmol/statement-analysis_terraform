variable "ecr_repository_url" { type = string }
variable "s3_bucket_name" { type = string }
variable "cognito_user_pool_id" { type = string }
variable "cognito_client_id" { type = string }
variable "sns_role" { type = string }
variable "sns_topic" { type = string }
variable "statement_analysis_function_name" {
  default = "statement-analysis-function"
}
variable "cognito_client_secret" {
  type      = string
  sensitive = true
}
