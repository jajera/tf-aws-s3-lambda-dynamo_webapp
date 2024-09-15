# tf-aws-s3-lambda-dynamo_webapp

## build terraform

```terraform
terraform init
```

```terraform
terraform apply --auto-approve --target=data.archive_file.dynamodb_mjs
```

```terraform
terraform apply --auto-approve
```

## build nodejs package

cd external/web

```bash
npm install
```

```bash
npm run build
```

## upload to s3

run another terraform apply to sync the build files to s3 bucket.

```terraform
terraform apply --auto-approve
```

## lambda test event

```bash
{
  "routeKey": "PUT /items",
  "pathParameters": "{}",
  "body": "{\"itemId\": \"123\", \"price\": 100, \"name\": \"Sample Item\"}",
  "requestContext": {
    "http": {
      "method": "PUT",
      "path": "/items"
    },
    "stage": "dev",
    "requestId": "example-request-id"
  }
}
```

```bash
{
  "routeKey": "GET /items"
}
```

```bash
{
  "routeKey": "OPTIONS /items"
}
```

```bash
{
  "routeKey": "GET /items/{id}",
  "pathParameters": "{\"id\": \"123\"}",
  "body": null,
  "requestContext": {
    "http": {
      "method": "GET",
      "path": "/items/123"
    },
    "stage": "dev",
    "requestId": "example-request-id"
  }
}
```

```bash
{
  "routeKey": "OPTIONS /items/{id}",
  "pathParameters": "{\"id\": \"123\"}",
  "body": null,
  "requestContext": {
    "http": {
      "method": "GET",
      "path": "/items/123"
    },
    "stage": "dev",
    "requestId": "example-request-id"
  }
}
```

```bash
{
  "routeKey": "DELETE /items/{id}",
  "pathParameters": "{\"id\": \"123\"}",
  "body": null,
  "requestContext": {
    "http": {
      "method": "DELETE",
      "path": "/items/123"
    },
    "stage": "dev",
    "requestId": "example-request-id"
  }
}
```

## cleanup

```terraform
terraform destroy --auto-approve
```

## reference

<https://www.youtube.com/watch?v=BFC16uM15Cg>
