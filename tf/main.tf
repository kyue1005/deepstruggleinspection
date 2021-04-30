provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "dev_vpc" {
  id = "vpc-0a77e06d"
}
