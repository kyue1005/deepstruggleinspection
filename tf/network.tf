resource "aws_subnet" "dev_subnet_a" {
  vpc_id            = data.aws_vpc.dev_vpc.id
  cidr_block        = "172.31.10.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "dev_subnet_b" {
  vpc_id            = data.aws_vpc.dev_vpc.id
  cidr_block        = "172.31.20.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "dev_subnet_c" {
  vpc_id            = data.aws_vpc.dev_vpc.id
  cidr_block        = "172.31.30.0/24"
  availability_zone = "us-east-1c"
}