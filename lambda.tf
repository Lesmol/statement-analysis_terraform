# resource "aws_lambda_function" "statement_analysis_function" {
#   function_name = "statement-analysis-function"
#   package_type = "Image"
#   image_uri = "${aws_ecr_repository.statement_analysis.repository_url}:latest"
#   role = aws_iam_role.statement_analysis_role.arn
#   memory_size = 2048
#   timeout = 60

#   architectures = [ "x86_64" ]
  
#   lifecycle {
#     ignore_changes = [ image_uri ]
#   }

#   environment {
#       variables = {
#       DYNAMODB_ACCOUNTS_TABLE_NAME = aws_dynamodb_table.statement_analysis_accounts.name
#       DYNAMODB_BANKS_TABLE_NAME = aws_dynamodb_table.statement_analysis_banks.name
#       DYNAMODB_STATEMENT_UPLOADS_TABLE_NAME = aws_dynamodb_table.statement_analysis_statement_uploads.name
#       DYNAMODB_USERS_TABLE_NAME = aws_dynamodb_table.statement_analysis_users.name
#       PORT                     = "8080"
#     }
#   }
# }
