resource "aws_lambda_function" "example" {
  function_name = local.name
  filename      = "${path.module}/external/dynamodb.zip"
  handler       = "index.handler"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.example.name
    }
  }

  role             = aws_iam_role.lambda.arn
  runtime          = "nodejs20.x"
  source_code_hash = base64sha256(file("${path.module}/external/dynamodb.mjs.tpl"))
  timeout          = 5
}

resource "aws_lambda_permission" "prod" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.example.id}/$default/$default"
}

resource "aws_lambda_permission" "prod_items" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.example.id}/*/*/items"
}

resource "aws_lambda_permission" "prod_items_by_id" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.example.id}/*/*/items/{id}"
}
