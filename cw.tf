# Create cloudwatch log group for lambda function

resource "aws_cloudwatch_log_group" "application_cloudwatch_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}