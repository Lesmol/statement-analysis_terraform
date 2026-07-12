data "aws_region" "current" {}

resource "aws_apigatewayv2_api" "statement_analysis_gw" {
  name          = var.api_gateway_name
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins     = split(",", var.cors_allowed_origins)
    allow_methods     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers     = ["Content-Type", "Authorization"]
    allow_credentials = true
    max_age           = 300
  }

  lifecycle {
    ignore_changes = [cors_configuration]
  }
}

resource "aws_cloudwatch_log_group" "statement_analysis_cloudwatch" {
  name              = "/aws/apigatewayv2/statement-analysis-api"
  retention_in_days = 14
}

resource "aws_apigatewayv2_stage" "statement_analysis_gw_stage" {
  api_id      = aws_apigatewayv2_api.statement_analysis_gw.id
  name        = "$default"
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

  integration_uri    = var.lambda_integration_invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_authorizer" "cognito" {
  api_id           = aws_apigatewayv2_api.statement_analysis_gw.id
  authorizer_type  = "JWT"
  name             = "cognito-authorizer"
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    issuer   = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${var.cognito_user_pool_id}"
    audience = [var.cognito_client_id]
  }
}

resource "aws_apigatewayv2_route" "statement_analysis_gw_route_proxy" {
  api_id             = aws_apigatewayv2_api.statement_analysis_gw.id
  route_key          = "ANY /{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.statement_analysis_gw_integration.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_route" "statement_analysis_gw_route_auth" {
  api_id             = aws_apigatewayv2_api.statement_analysis_gw.id
  route_key          = "ANY /api/{version}/auth/{proxy+}"
  target             = "integrations/${aws_apigatewayv2_integration.statement_analysis_gw_integration.id}"
  authorization_type = "NONE"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.statement_analysis_gw.execution_arn}/*/*"
}

# Widens CORS to include the Amplify app's domain once it's known. Can't be
# done inline on aws_apigatewayv2_api because that would create a cycle:
# this API's gateway_url feeds module.amplify's REACT_APP_API_URL env var,
# so amplify.default_domain can't also feed back into this resource's creation.
resource "null_resource" "add_amplify_cors_origin" {
  triggers = {
    api_id  = aws_apigatewayv2_api.statement_analysis_gw.id
    origins = "https://${var.amplify_domain},${var.cors_allowed_origins}"
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws apigatewayv2 update-api \
        --api-id ${aws_apigatewayv2_api.statement_analysis_gw.id} \
        --region ${data.aws_region.current.name} \
        --cors-configuration '${jsonencode({
    AllowOrigins     = split(",", "https://${var.amplify_domain},${var.cors_allowed_origins}")
    AllowMethods     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    AllowHeaders     = ["Content-Type", "Authorization"]
    AllowCredentials = true
    MaxAge           = 300
})}'
    EOT
  }
}
