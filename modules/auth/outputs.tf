output "user_pool_id" {
  value = aws_cognito_user_pool.statement_analysis.id
}

output "client_id" {
  value = aws_cognito_user_pool_client.statement_analysis.id
}

output "client_secret" {
  value     = aws_cognito_user_pool_client.statement_analysis.client_secret
  sensitive = true
}