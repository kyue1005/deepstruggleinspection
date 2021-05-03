provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "dev_vpc" {
  id = "vpc-0a77e06d"
}

resource "aws_key_pair" "dev_key" {
  key_name   = "dev-key"
  public_key = var.dev_ssh_key
}

data "aws_security_group" "default" {
  id = "sg-ff8a8f84"
}