data "aws_ami" "url_shortener_ami" {
  most_recent = true
  name_regex  = "^url_shorter_ubuntu_.*"
  owners      = [var.aws_account_id]

  filter {
    name   = "name"
    values = ["url_shorter_ubuntu_*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_instance_profile" "url_shortener_profile" {
  name = "url-shortener-profile"
  role = aws_iam_role.url_shortener_role.name
}

resource "aws_security_group" "url_shortener_instance_sg" {
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
      "0.0.0.0/0",
    ]
    from_port        = 0
    ipv6_cidr_blocks = []
    protocol         = "-1"
    to_port          = 0
  }
  name   = "url-shortener-instance-sg"
  vpc_id = data.aws_vpc.dev_vpc.id
}



resource "aws_launch_configuration" "url_shortener_conf" {
  name_prefix   = "url-shortener-"
  image_id      = data.aws_ami.url_shortener_ami.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.dev_key.key_name

  iam_instance_profile = aws_iam_instance_profile.url_shortener_profile.name

  security_groups = [aws_security_group.url_shortener_instance_sg.id]

  associate_public_ip_address = true

  user_data = "${file("./scripts/service.sh")}"

  lifecycle {
    create_before_destroy = true
  }
}

module "url_shortener_asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  name = "url-shortener-asg"

  min_size         = 2
  max_size         = 10
  desired_capacity = 2

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  vpc_zone_identifier = [
    aws_subnet.url_shortener_subnet_a.id,
    aws_subnet.url_shortener_subnet_b.id,
    aws_subnet.url_shortener_subnet_c.id
  ]
  target_group_arns = module.url_shortener_alb.target_group_arns

  use_lc               = true
  launch_configuration = aws_launch_configuration.url_shortener_conf.name

  tags = [
    {
      key                 = "Project"
      value               = "url-shortener"
      propagate_at_launch = true
    },
  ]
}

resource "aws_autoscaling_policy" "url_shortener_asg_policy" {
  name                   = "url-shortener-asg-policy"
  autoscaling_group_name = module.url_shortener_asg.autoscaling_group_name

  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }
}