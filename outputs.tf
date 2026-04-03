output "dynamodb_banks_table_name" {
  description = "Name of the DynamoDB banks table"
  value       = aws_dynamodb_table.statement_analysis_banks.name
}

output "dynamodb_users_table_name" {
  description = "Name of the DynamoDB users table"
  value       = aws_dynamodb_table.statement_analysis_users.name
}

output "dynamodb_accounts_table_name" {
  description = "Name of the DynamoDB accounts table"
  value       = aws_dynamodb_table.statement_analysis_accounts.name
}

output "dynamodb_statement_uploads_table_name" {
  description = "Name of the DynamoDB statement uploads table"
  value       = aws_dynamodb_table.statement_analysis_statement_uploads.name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for statements"
  value       = aws_s3_bucket.statement_analysis_statements.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for statements"
  value       = aws_s3_bucket.statement_analysis_statements.arn
  sensitive   = true
}

output "cognito_user_pool_id" {
  description = "ID of the Cognito user pool"
  value       = aws_cognito_user_pool.statement_analysis_user_pool.id
  sensitive   = true
}

output "cognito_user_pool_arn" {
  description = "ARN of the Cognito user pool"
  value       = aws_cognito_user_pool.statement_analysis_user_pool.arn
  sensitive   = true
}

output "cognito_app_client_id" {
  description = "ID of the Cognito app client"
  value       = aws_cognito_user_pool_client.statement_analysis_app_client.id
  sensitive   = true
}

output "cognito_jwks_uri" {
  description = "JWKS URI for Cognito user pool (used by API Gateway JWT Authorizer)"
  value       = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.statement_analysis_user_pool.id}/.well-known/jwks.json"
  sensitive   = true
}

# IAM
output "iam_app_role_arn" {
  description = "ARN of the IAM role for the Spring Boot application"
  value       = aws_iam_role.statement_analysis_app_role.arn
  sensitive   = true
}