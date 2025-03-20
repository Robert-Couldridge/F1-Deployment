variable "application_region" {
  description = "The Chosen AWS region for the application"
  type        = string
  default     = "us-east-1"
}

variable "acountId" {
  description = "The AWS account ID"
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the lambda function"
  type        = string
  default     = "Overtake prediction"
}

variable "endpoint_path" {
  description = "The GET endpoint path"
  type        = string
  default     = "overtake_prediction"
}