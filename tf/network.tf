resource "aws_subnet" "url_shortener_subnet_a" {
  vpc_id                  = data.aws_vpc.dev_vpc.id
  cidr_block              = var.subnet_a_cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "url-shortener-subnet-a"
  }
}

resource "aws_subnet" "url_shortener_subnet_b" {
  vpc_id                  = data.aws_vpc.dev_vpc.id
  cidr_block              = var.subnet_b_cidr
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "url-shortener-subnet-b"
  }
}

resource "aws_subnet" "url_shortener_subnet_c" {
  vpc_id                  = data.aws_vpc.dev_vpc.id
  cidr_block              = var.subnet_c_cidr
  availability_zone       = "us-east-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "url-shortener-subnet-c"
  }
}