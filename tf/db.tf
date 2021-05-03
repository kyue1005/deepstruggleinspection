module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name     = var.dynamodb_table_name
  hash_key = "key"

  attributes = [
    {
      name = "key"
      type = "S"
    },
  ]

  tags = {
    Environment = "dev"
    Name        = "short-url-map"
  }
}