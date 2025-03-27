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
  shared_credentials_files = [".aws/credentials"]
  profile                  = "default"
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
  role          = var.lab_role
  handler       = "main.lambda_handler"
  runtime       = "python3.8"
  depends_on    = [aws_cloudwatch_log_group.application_cloudwatch_log_group, data.archive_file.zip_the_python_code]
}

# Create cloudwatch log group

resource "aws_cloudwatch_log_group" "application_cloudwatch_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

# Create API gateway

resource "aws_api_gateway_rest_api" "application_api" {
  name = "application_api"
}

resource "aws_api_gateway_resource" "application_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.application_api.id
  parent_id   = aws_api_gateway_rest_api.application_api.root_resource_id
  path_part   = var.endpoint_path
}

# resource "aws_api_gateway_method" "application_api_get_method" {
#   rest_api_id   = aws_api_gateway_rest_api.application_api.id
#   resource_id   = aws_api_gateway_resource.application_api_resource.id
#   http_method   = "GET"
#   authorization = "NONE"
# }

resource "aws_api_gateway_method" "application_api_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.application_api.id
  resource_id   = aws_api_gateway_resource.application_api_resource.id
  http_method   = "POST"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.Content-Type" = true
  }
}

# Create API gateway and Lambda integration

resource "aws_api_gateway_integration" "application_integration" {
  rest_api_id             = aws_api_gateway_rest_api.application_api.id
  resource_id             = aws_api_gateway_resource.application_api_resource.id
  http_method             = aws_api_gateway_method.application_api_post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.application_lambda_func.invoke_arn

  request_templates = {
    "application/json" = <<EOF
    {
      "body": "$input.body"
    }
    EOF
  }
  depends_on = [ aws_api_gateway_resource.application_api_resource ]
}

resource "aws_api_gateway_method_response" "application_api_method_response"{
  rest_api_id = aws_api_gateway_rest_api.application_api.id
  resource_id = aws_api_gateway_resource.application_api_resource.id
  http_method = aws_api_gateway_method.application_api_post_method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  // cors 
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "application_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.application_api.id
  resource_id = aws_api_gateway_resource.application_api_resource.id
  http_method = aws_api_gateway_method.application_api_post_method.http_method
  status_code = aws_api_gateway_method_response.application_api_method_response.status_code

  response_templates = {
    "application/json" = ""
  }
  
  // cors
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [ 
  aws_api_gateway_method.application_api_post_method,
  aws_api_gateway_integration.application_integration
  ]
}

# Permissions

resource "aws_lambda_permission" "apigw_lambda" {
  # statement_id  = "AllowExecutionFromAPIGateway"
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.application_lambda_func.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.application_region}:${var.account_id}:${aws_api_gateway_rest_api.application_api.id}/*/${aws_api_gateway_method.application_api_post_method.http_method}${aws_api_gateway_resource.application_api_resource.path}"
}

# Deployment

resource "aws_api_gateway_deployment" "application_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.application_api.id

  # triggers = {
  #   redeployment = sha1(jsondecode(aws_api_gateway_rest_api.application_api.body))
  # }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [aws_api_gateway_method.application_api_post_method, aws_api_gateway_integration.application_integration]
}

resource "aws_api_gateway_stage" "application_api_stage" {
  deployment_id = aws_api_gateway_deployment.application_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.application_api.id
  stage_name    = "dev"

  depends_on = [ aws_api_gateway_deployment.application_api_deployment ]
}


