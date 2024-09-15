
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  name = "s3-lambda-dynamo-webapp-${random_string.suffix.result}"

  source_web = "${path.module}/external/web/build"

  files = [
    for file in fileset(local.source_web, "**/*") : {
      path = "${local.source_web}/${file}",
      dest = file
    }
  ]

  content_types = {
    ".html" = "text/html",
    ".css"  = "text/css",
    ".js"   = "application/javascript",
    ".jpg"  = "image/jpeg",
    ".jpeg" = "image/jpeg",
    ".png"  = "image/png",
    ".json" = "application/json",
  }
}

data "template_file" "dynamodb_mjs" {
  template = file("${path.module}/external/dynamodb.mjs.tpl")
}

data "archive_file" "dynamodb_mjs" {
  type        = "zip"
  output_path = "${path.module}/external/dynamodb.zip"

  source {
    content  = data.template_file.dynamodb_mjs.rendered
    filename = "index.mjs"
  }
}

resource "local_file" "config_ts" {
  filename = "${path.module}/external/web/src/config.ts"

  content = <<-EOF
    export const apiEndpoint = '${aws_apigatewayv2_api.example.api_endpoint}/prod'
  EOF
}

resource "null_resource" "cleanup" {
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      rm -rf "${path.module}/external/dynamodb.zip"
    EOT
  }
}

output "http_apigateway_endpoint_url" {
  value = aws_apigatewayv2_api.example.api_endpoint
}

output "s3_bucket_index_html_url" {
  value = "https://${aws_s3_bucket.example.bucket_regional_domain_name}/index.html"
}
