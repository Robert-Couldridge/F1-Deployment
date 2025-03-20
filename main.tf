terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.91.0"
    }
  }
}

provider "aws" {
  region                   = var.application_region
  access_key = var.accessKey
  secret_key = var.secretKey
}

# IAM role creation (may not work in lab)

resource "aws_iam_role" "lambda_role" {
  name               = "terraform_aws_lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM policy for logging from a lambda

resource "aws_iam_policy" "iam_policy_for_lambda" {

  name        = "aws_iam_policy_for_terraform_aws_lambda_role"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

# Policy Attachment on the role.

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
}

# Generates an archive from content, a file, or a directory of files.

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/deployment-package.zip"
}

# Create a lambda function
# In terraform ${path.module} is the current directory.

resource "aws_lambda_function" "application_lambda_func" {
  filename      = "${path.module}/python/deployment-package.zip"
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "main.lambda_handler"
  runtime       = "python3.8"
  depends_on    = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}

# Create cloudwatch log group

resource "aws_cloudwatch_log_group" "name" {
  name = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

# Create API gateway

resource "aws_api_gateway_rest_api" "application_api" {
  name = "application_api"
}

resource "aws_api_gateway_resource" "application_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.application_api.id
  parent_id   = aws_api_gateway_resource.application_api_resource.id
  path_part   = var.endpoint_path
}

resource "aws_api_gateway_method" "application_api_method" {
  rest_api_id   = aws_api_gateway_rest_api.application_api.id
  resource_id   = aws_api_gateway_resource.application_api_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Create API gateway and Lambda integration

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.application_api.id
  resource_id             = aws_api_gateway_resource.application_api_resource.id
  http_method             = aws_api_gateway_method.application_api_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.application_lambda_func.invoke_arn
}

# Permissions

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.application_lambda_func.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.application_region}:${var.acountId}:${aws_api_gateway_rest_api.application_api.id}/*/${aws_api_gateway_method.application_api_method.http_method}${aws_api_gateway_resource.application_api_resource.path}"
}

# Deployment

resource "aws_api_gateway_deployment" "application_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.application_api.id

  triggers = {
    redeployment = sha1(jsondecode(aws_api_gateway_rest_api.application_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_api_gateway_method.application_api_method, aws_api_gateway_integration.integration]
}

resource "aws_api_gateway_stage" "application_api_stage" {
  deployment_id = aws_api_gateway_deployment.application_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.application_api.id
  stage_name    = "dev"
}

