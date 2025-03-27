variable "application_region" {
  description = "The Chosen AWS region for the application"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "lab_role" {
  description = "The Lab role provided by AWS"
  type        = string
}


variable "lambda_function_name" {
  description = "The name of the lambda function"
  type        = string
  default     = "overtake_prediction"
}

variable "endpoint_path" {
  description = "The GET endpoint path"
  type        = string
  default     = "overtake_prediction"
}

variable "destination_email_address" {
  description = "The email address the overtake predictions should be sent to"
  type        = string
}