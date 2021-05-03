resource "aws_subnet" "url_shortener_subnet_a" {
  vpc_id            = data.aws_vpc.dev_vpc.id
  cidr_block        = "172.31.20.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "url-shortener-subnet-a"
  }
}

resource "aws_subnet" "url_shortener_subnet_b" {
  vpc_id            = data.aws_vpc.dev_vpc.id
  cidr_block        = "172.31.30.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "url-shortener-subnet-b"
  }
}

resource "aws_subnet" "url_shortener_subnet_c" {
  vpc_id            = data.aws_vpc.dev_vpc.id
  cidr_block        = "172.31.40.0/24"
  availability_zone = "us-east-1c"


  tags = {
    Name = "url-shortener-subnet-c"
  }
}