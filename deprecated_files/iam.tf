# IAM role creation (may not work in lab)

# resource "aws_iam_role" "lambda_role" {
#   name               = "terraform_aws_lambda_role"
#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": "sts:AssumeRole",
#       "Principal": {
#         "Service": "lambda.amazonaws.com"
#       },
#       "Effect": "Allow",
#       "Sid": ""
#     }
#   ]
# }
# EOF
# }

# IAM policy for logging from a lambda

# resource "aws_iam_policy" "iam_policy_for_lambda" {

#   name        = "aws_iam_policy_for_terraform_aws_lambda_role"
#   path        = "/"
#   description = "AWS IAM Policy for managing aws lambda role"
#   policy      = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Action": [
#         "logs:CreateLogGroup",
#         "logs:CreateLogStream",
#         "logs:PutLogEvents"
#       ],
#       "Resource": "arn:aws:logs:*:*:*",
#       "Effect": "Allow"
#     },
#     {
#       "Action": [
#       "lambda:InvokeFunction"
#       ],
#       "Resource": "*",
#       "Effect": "Allow"
#     }
#   ]
# }
# EOF
# }

# # Policy Attachment on the role.

# resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_lab_role" {
#   role       = var.lab_role
#   policy_arn = aws_iam_policy.iam_policy_for_lambda.arn
# }