output "app_id" {
  value = aws_amplify_app.statement_analysis.id
}

output "default_domain" {
  value = "${aws_amplify_branch.main.branch_name}.${aws_amplify_app.statement_analysis.default_domain}"
}