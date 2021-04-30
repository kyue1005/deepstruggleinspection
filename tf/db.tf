resource "random_pet" "this" {
  length = 2
}

module "dynamodb_table" {
  source = "terraform-aws-modules/dynamodb-table/aws"

  name     = "short-url-map-${random_pet.this.id}"
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