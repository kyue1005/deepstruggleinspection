
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
  vpc_id = data.aws_vpc.dev_vpc.id
}

resource "aws_iam_instance_profile" "ec2_read_only" {
  name = "ec2-read-only"
  role = aws_iam_role.ec2_read_only.name
}

resource "aws_key_pair" "dev_key" {
  key_name   = "dev-key"
  public_key = var.dev_ssh_key
}

resource "aws_eip_association" "dev_eip_assoc" {
  instance_id   = aws_instance.dev.id
  allocation_id = aws_eip.dev.id
}

resource "aws_instance" "dev" {
  ami                         = var.dev_ssh_ami
  associate_public_ip_address = "true"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.dev_key.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_read_only.name
  subnet_id                   = aws_subnet.dev_subnet_a.id
  vpc_security_group_ids      = [aws_security_group.dev_ssh_sg.id]

  tags = {
    Name = "dev"
  }
}
