resource "aws_api_gateway_rest_api" "statement_analysis_api" {
  name        = "statement-analysis-api"
  description = "REST API Gateway for Statement Analysis Lambda"
}

resource "aws_api_gateway_resource" "statement_analysis_proxy" {
  rest_api_id = aws_api_gateway_rest_api.statement_analysis_api.id
  parent_id   = aws_api_gateway_rest_api.statement_analysis_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "statement_analysis_proxy_method" {
  rest_api_id      = aws_api_gateway_rest_api.statement_analysis_api.id
  resource_id      = aws_api_gateway_resource.statement_analysis_proxy.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "statement_analysis_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.statement_analysis_api.id
  resource_id             = aws_api_gateway_resource.statement_analysis_proxy.id
  http_method             = aws_api_gateway_method.statement_analysis_proxy_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.statement_analysis_function.invoke_arn
}

resource "aws_api_gateway_deployment" "statement_analysis_deployment" {
  depends_on = [aws_api_gateway_integration.statement_analysis_lambda_integration]
  rest_api_id = aws_api_gateway_rest_api.statement_analysis_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.statement_analysis_proxy.id,
      aws_api_gateway_method.statement_analysis_proxy_method.id,
      aws_api_gateway_integration.statement_analysis_lambda_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "statement_analysis_prod" {
  deployment_id = aws_api_gateway_deployment.statement_analysis_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.statement_analysis_api.id
  stage_name    = "prod"
}

resource "aws_api_gateway_api_key" "statement_analysis_api_key" {
  name    = "statement-analysis-client-key"
  enabled = true
}

resource "aws_api_gateway_usage_plan" "statement_analysis_usage_plan" {
  name = "statement-analysis-basic-tier"

  api_stages {
    api_id = aws_api_gateway_rest_api.statement_analysis_api.id
    stage  = aws_api_gateway_stage.statement_analysis_prod.stage_name
  }

  throttle_settings {
    burst_limit = 20
    rate_limit  = 10
  }
}

resource "aws_api_gateway_usage_plan_key" "statement_analysis_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.statement_analysis_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.statement_analysis_usage_plan.id
}

resource "aws_lambda_permission" "statement_analysis_apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.statement_analysis_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.statement_analysis_api.execution_arn}/*/*"
}