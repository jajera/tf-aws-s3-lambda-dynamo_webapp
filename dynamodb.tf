resource "aws_dynamodb_table" "example" {
  name         = local.name
  billing_mode = "PROVISIONED"

  attribute {
    name = "itemId"
    type = "S"
  }

  hash_key = "itemId"

  read_capacity  = 1
  write_capacity = 1

  timeouts {
    create = "10m"
    update = "10m"
    delete = "10m"
  }

  lifecycle {
    prevent_destroy = false
  }
}
