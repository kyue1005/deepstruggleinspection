resource "aws_security_group" "url_shortener_lb_sg" {
  description = "Url shortener alb security group"
  name        = "url-shortener-lb-sg"
  vpc_id      = data.aws_vpc.dev_vpc.id
}

resource "aws_security_group_rule" "url_shortener_lb_ingress" {
  type              = "ingress"
  to_port           = 80
  protocol          = "tcp"
  from_port         = 80
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.url_shortener_lb_sg.id
  description       = "http"
}

resource "aws_security_group_rule" "url_shortener_lb_egress" {
  type                     = "egress"
  to_port                  = 80
  protocol                 = "tcp"
  from_port                = 80
  source_security_group_id = aws_security_group.url_shortener_instance_sg.id
  security_group_id        = aws_security_group.url_shortener_lb_sg.id
  description              = "asg instance"
}

module "url_shortener_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name = "url-shortener-alb"

  load_balancer_type = "application"

  vpc_id = data.aws_vpc.dev_vpc.id
  subnets = [
    aws_subnet.url_shortener_subnet_a.id,
    aws_subnet.url_shortener_subnet_b.id,
    aws_subnet.url_shortener_subnet_c.id
  ]
  security_groups = [aws_security_group.url_shortener_lb_sg.id]

  target_groups = [
    {
      name             = "url-shortener-tg"
      backend_port     = 80
      backend_protocol = "HTTP"
      health_check = {
        healthy_threshold   = 5
        unhealthy_threshold = 2
        path                = "/healthz"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "dev"
    Project     = "url-shortener"
  }
}