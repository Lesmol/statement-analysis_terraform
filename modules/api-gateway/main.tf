resource "aws_apigatewayv2_api" "statement_analysis_gw" {
  name = var.api_gateway_name
  protocol_type = "HTTP"
}

resource "aws_cloudwatch_log_group" "statement_analysis_cloudwatch" {
  name              = "/aws/apigatewayv2/statement-analysis-api"
  retention_in_days = 14
}

resource "aws_apigatewayv2_stage" "statement_analysis_gw_stage" {
  api_id = aws_apigatewayv2_api.statement_analysis_gw.id
  name = "prod"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.statement_analysis_cloudwatch.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_integration" "statement_analysis_gw_integration" {
  api_id = aws_apigatewayv2_api.statement_analysis_gw.id

  integration_uri = var.lambda_integration_invoke_arn
  integration_type = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "statement_analysis_gw_route" {
  api_id = aws_apigatewayv2_api.statement_analysis_gw.id

  route_key = "POST /statement-analysis"
  target = "integrations/${aws_apigatewayv2_integration.statement_analysis_gw_integration.id}"
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.statement_analysis_gw.execution_arn}/*/*"
}
