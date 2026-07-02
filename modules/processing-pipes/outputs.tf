output "topic_arn" {
  value = aws_sns_topic.statement_analysis_textract_completion_topic.arn
  sensitive = true  
}

output "role_arn" {
  value = aws_iam_role.textract_sns_role.arn
  sensitive = true
}