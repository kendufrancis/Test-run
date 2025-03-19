# ---elb/main.tf/module---
# Create alb
resource "aws_lb" "lms_alb" {
  name               = var.alb_name 
  internal           = false
  load_balancer_type = var.load_balancer_type
  subnets = aws_subnet.lms_public_subnet.id[each.key]
  security_groups = aws_security_group.lms_sg.id
#   desync_mitigation_mode           = "defensive"
  enable_cross_zone_load_balancing = true
  enable_http2                     = true
  idle_timeout                     = 300
  ip_address_type                  = "dualstack"

  tags = {
    Name = var.alb_name
    Environment = var.environment
  }
}

# Create a listeners for HTTP target group 
resource "aws_lb_listener" "lms_http_listener" {
  load_balancer_arn = aws_lb.lms_alb.arn
  port              = service_ports["http"]
  protocol          = locals.service_protocols["http"]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lms_http_tg.arn
  }

#   tags = {
#     Name        = "${var.alb_name}-listener"
#     Environment = locals.environment
#   }
}

# Create a listeners for HTTPS target group 
resource "aws_lb_listener" "lms_https_listener" {
  load_balancer_arn = aws_lb.lms_alb.arn
  port              = service_ports["https"]
  protocol          = locals.service_protocols["https"]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lms_https_tg.arn
  }
}
# Create HTTP target group
resource "aws_lb_target_group" "lms_http_tg" {
  name             = var.http_target_group_name
  port             = locals.service_ports["http"]
  protocol         = locals.service_protocols["http"]
  target_type      = data.aws_ami.ami.id
  vpc_id           = aws_vpc.lms_vpc.id
  load_balancing_algorithm_type = "round_robin"
  health_check {
    enabled = true
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    interval            = var.health_check_interval
    matcher = "200"
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = locals.service_protocols["http"]
    timeout             = var.health_check_timeout
  }
  # stickiness { 
  #   cookie_duration = 86400
  #   enabled         = false
  # #   type            = "lb_cookie"
  # }
  tags = {
    Environment = var.environment 
    Name        = var.http_target_group_name
  }
}

# Create a HTTPS target group
resource "aws_lb_target_group" "lms_https_tg" {
  name             = var.https_target_group_name
  port             = locals.service_ports["https"]
  protocol         = locals.service_protocols["https"]
  target_type      = data.aws_ami.ami.id
  vpc_id           = aws_vpc.lms_vpc.id
  load_balancing_algorithm_type = "round_robin"
  health_check {
    enabled = true
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    interval            = var.health_check_interval
    matcher = "200"
    path                = var.health_check_path
    port                = "traffic-port"
    protocol            = locals.service_protocols["https"]
    timeout             = var.health_check_timeout
  }
  # stickiness { 
  #   cookie_duration = 86400
  #   enabled         = false
  # #   type            = "lb_cookie"
  # }
  tags = {
    Environment = var.environment 
    Name        = var.https_target_group_name
  }
}