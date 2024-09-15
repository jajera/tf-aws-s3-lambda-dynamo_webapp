resource "aws_apigatewayv2_api" "example" {
  name = local.name

  cors_configuration {
    allow_methods     = ["*"]
    allow_origins     = ["https://${aws_s3_bucket.example.bucket_regional_domain_name}"]
    allow_headers     = ["*"]
    allow_credentials = true
    expose_headers    = ["*"]
    max_age           = 96400
  }

  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.example.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigateway_default.arn
    format = jsonencode({
      requestId      = "$context.requestId",
      sourceIp       = "$context.identity.sourceIp",
      httpMethod     = "$context.httpMethod",
      status         = "$context.status",
      protocol       = "$context.protocol",
      responseLength = "$context.responseLength"
    })
  }

  depends_on = [
    aws_apigatewayv2_route.default
  ]
}

resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.example.id
  name        = "prod"
  auto_deploy = false

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.apigateway_prod.arn
    format = jsonencode({
      requestId      = "$context.requestId",
      sourceIp       = "$context.identity.sourceIp",
      httpMethod     = "$context.httpMethod",
      status         = "$context.status",
      protocol       = "$context.protocol",
      responseLength = "$context.responseLength"
    })
  }

  deployment_id = aws_apigatewayv2_deployment.prod.id
}

resource "aws_apigatewayv2_deployment" "prod" {
  api_id      = aws_apigatewayv2_api.example.id
  description = "Automatic deployment triggered by changes to the Api configuration"

  triggers = {
    redeployment = sha1(join(",", tolist([
      jsonencode(aws_apigatewayv2_integration.prod),
      jsonencode(aws_apigatewayv2_route.items_get),
      jsonencode(aws_apigatewayv2_route.items_options),
      jsonencode(aws_apigatewayv2_route.items_put),
      jsonencode(aws_apigatewayv2_route.items_id_delete),
      jsonencode(aws_apigatewayv2_route.items_id_get),
      jsonencode(aws_apigatewayv2_route.items_id_options)
    ])))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_integration" "default" {
  api_id                 = aws_apigatewayv2_api.example.id
  connection_type        = "INTERNET"
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.example.invoke_arn
  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "default" {
  api_id    = aws_apigatewayv2_api.example.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.default.id}"
}

resource "aws_apigatewayv2_integration" "prod" {
  api_id                 = aws_apigatewayv2_api.example.id
  connection_type        = "INTERNET"
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.example.invoke_arn
  passthrough_behavior   = "WHEN_NO_MATCH"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "items_get" {
  api_id    = aws_apigatewayv2_api.example.id
  route_key = "GET /items"
  target    = "integrations/${aws_apigatewayv2_integration.prod.id}"
}

resource "aws_apigatewayv2_route" "items_options" {
  api_id    = aws_apigatewayv2_api.example.id
  route_key = "OPTIONS /items"
  target    = "integrations/${aws_apigatewayv2_integration.prod.id}"
}

resource "aws_apigatewayv2_route" "items_put" {
  api_id    = aws_apigatewayv2_api.example.id
  route_key = "PUT /items"
  target    = "integrations/${aws_apigatewayv2_integration.prod.id}"
}

resource "aws_apigatewayv2_route" "items_id_delete" {
  api_id    = aws_apigatewayv2_api.example.id
  route_key = "DELETE /items/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.prod.id}"
}

resource "aws_apigatewayv2_route" "items_id_get" {
  api_id    = aws_apigatewayv2_api.example.id
  route_key = "GET /items/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.prod.id}"
}

resource "aws_apigatewayv2_route" "items_id_options" {
  api_id    = aws_apigatewayv2_api.example.id
  route_key = "OPTIONS /items/{id}"
  target    = "integrations/${aws_apigatewayv2_integration.prod.id}"
}
