# Create SNS topic and subscribe desired email address

resource "aws_sns_topic" "sns_topic" {
  name = "overtake-prediction"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.sns_topic.arn
  protocol  = "email"
  endpoint  = var.destination_email_address
}