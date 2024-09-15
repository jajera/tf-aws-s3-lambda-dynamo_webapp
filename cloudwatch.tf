resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${local.name}"
  retention_in_days = 1

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_cloudwatch_log_group" "apigateway_default" {
  name              = "/aws/apigateway/${local.name}/default"
  retention_in_days = 1

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_cloudwatch_log_group" "apigateway_prod" {
  name              = "/aws/apigateway/${local.name}/prod"
  retention_in_days = 1

  lifecycle {
    prevent_destroy = false
  }
}
