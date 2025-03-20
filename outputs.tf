output "endpoint_url" {
  value = "${aws_api_gateway_stage.application_api_stage.invoke_url}/${var.endpoint_path}"
}