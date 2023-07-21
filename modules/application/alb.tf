resource "aws_lb" "backend_alb" {
  name               = "${var.environment}-backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.alb_sg.security_group_id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_listener" "backend_alb_listener" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn = aws_acm_certificate_validation.alb_cert_validation.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_alb_target.arn
  }
}

resource "aws_lb_target_group" "backend_alb_target" {
  name     = "${var.environment}-backend-target-group"
  port     = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = module.vpc.vpc_id
  lifecycle {
      create_before_destroy = true
  }
  deregistration_delay = 45
  health_check {
    path     = "/api/healthcheck/"
    port     = 80
    protocol = "HTTP"
    healthy_threshold = 2
    interval = 30
    timeout = 10
    unhealthy_threshold = 5
  }
}


module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.environment}-backend-alb-sg"
  description = "ALB security group for backend. Set to allow all HTTP traffic"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]

  egress_rules = ["all-all"]

  tags = {
    Environment = var.environment
  }
}