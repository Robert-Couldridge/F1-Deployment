# Create and populate DyanamoDB table using tyre_wear_data.csv file

resource "aws_dynamodb_table" "application_dynamo_db_table" {
  name         = "Tyre-Wear-Table"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "lap"
    type = "N"
  }

  hash_key = "lap"
}

locals {
  tyre_wear_data = csvdecode(file("data/tyre_wear_data.csv"))
}

resource "aws_dynamodb_table_item" "tyre_wear_information" {
  for_each = { for row in local.tyre_wear_data : row.lap => row }

  table_name = aws_dynamodb_table.application_dynamo_db_table.name
  hash_key   = aws_dynamodb_table.application_dynamo_db_table.hash_key

  item = <<EOF
  {
    "lap": {"N": "${each.value.lap}"},
    "soft": {"N": "${each.value.soft}"},
    "medium": {"N": "${each.value.medium}"},
    "hard": {"N": "${each.value.hard}"}
  }
  EOF

  lifecycle {
    ignore_changes = [item]
  }
}