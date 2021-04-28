resource "aws_vpc" "dev_vpc" {
  cidr_block = "172.31.0.0/16"
}

resource "aws_subnet" "dev_subnet" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "172.31.10.0/24"
  availability_zone = "ap-southeast-1a"
}

resource "aws_eip" "dev" {
  vpc = true
}

resource "aws_security_group" "dev_ssh_sg" {
  description = "default VPC security group"
  egress {
    cidr_blocks = [
      "0.0.0.0/0",
    ]
    from_port        = 0
    ipv6_cidr_blocks = []
    protocol         = "-1"
    to_port          = 0
  }

  ingress {
    cidr_blocks = [
      "113.254.184.209/32"
    ]
    from_port        = 22
    ipv6_cidr_blocks = []
    protocol         = "tcp"
    to_port          = 22
  }
  name   = "dev-ssh-sg"
  vpc_id = aws_vpc.dev_vpc.id
}

resource "aws_iam_instance_profile" "ec2_read_only" {
  name = "ec2-read-only"
  role = aws_iam_role.ec2_read_only.name
}

resource "aws_key_pair" "dev_key" {
  key_name   = "dev-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC6nztSxR8wbfrFsJgS9DiFzToceMprnMugOs5r2mhReB0ACXs+HEUaV2FuDomgUT5d2H1x+KrQCANYOBN1WrvbL+z35iGv1wAd2bvfU6QLqa7IOEYXar5XXuDLMwPC35bqEI+Ex+sGTXBZlqJHm3NgVtbUZc/LvM55DM/MZ4K3nbxrM5Vjfmk5fj1WZYscI3caLisyWJqUEXr6/ypnh5Pny+zbcAoUkcNK0KCHqjO4eTVl04JTHTlAWyHyoqXQ8kj1jPhONc3C+xd2/aJF1APc96pR6+xkUooL6jr0qnsrbjNDMo2AK0GlRCektAUihikqyzK0DS9aFjVK1E08Xy2jr64NJYQlT/NeDS5vsbdLxx9jUwR5EUFnsr3PtkkOKxbcnN2c/EiDcGA3p31LkfGZSXB1zphqEdXcJSoLwmf0o7wh7OaFoo11T9A3boeKwQ3sk8e/+UC0FdzPNt2YM6Ih9qohebOEEDdNZ3OGp5smCvMoRb+psOFOIWiERlROflU= kelvin.yue@MacBook-Pro.local"
}

resource "aws_eip_association" "dev_eip_assoc" {
  instance_id   = aws_instance.dev.id
  allocation_id = aws_eip.dev.id
}

resource "aws_instance" "dev" {
  ami                         = "ami-03ca998611da0fe12"
  associate_public_ip_address = "true"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.dev_key.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_read_only.name
  subnet_id                   = aws_subnet.dev_subnet.id
  vpc_security_group_ids      = [aws_security_group.dev_ssh_sg.id]
}
