output "statement_analysis_function_invoke_arn" {
  value = aws_lambda_function.statement_analysis_function.invoke_arn
}

output "statement_analysis_function_name" {
  value = aws_lambda_function.statement_analysis_function.function_name
}
