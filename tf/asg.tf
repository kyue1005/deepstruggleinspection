data "aws_ami" "url_shortener" {
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

resource "aws_iam_instance_profile" "url_shortener" {
  name = "url-shortener"
  role = aws_iam_role.url_shortener.name
}

resource "aws_autoscaling_policy" "url_shortener" {
  name                   = "url-shortener-asg-policy"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = module.url_shortener_asg.autoscaling_group_name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }
}

resource "aws_launch_template" "url_shortener" {
  name          = "url-shortener-template"
  image_id      = data.aws_ami.url_shortener.id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.dev_key.key_name

  vpc_security_group_ids = ["sg-12345678"]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Environment = "dev"
      Project = "url-shortener"
    }
  }
}

module "url_shortener_asg" {
  source = "terraform-aws-modules/autoscaling/aws"
  name   = "url-shortener-asg"

  min_size = 1
  max_size = 2

  vpc_zone_identifier = [
    aws_subnet.dev_subnet_a.id,
    aws_subnet.dev_subnet_b.id,
    aws_subnet.dev_subnet_c.id
  ]

  use_lt          = true
  launch_template = aws_launch_template.url_shortener.name

  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "url-shortener"
      propagate_at_launch = true
    },
  ]
}