# Security Group ALB
resource "aws_security_group" "this_alb" {
  name        = "${var.app_name}-${var.environment}-alb-sg"
  description = "Security Group ALB NovaSphere"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.app_name}-${var.environment}-alb-sg"
    Environment = var.environment
  }
}

# Security Group instances
resource "aws_security_group" "this_web" {
  name        = "${var.app_name}-${var.environment}-web-sg"
  description = "Security Group instances NovaSphere"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.this_alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.app_name}-${var.environment}-web-sg"
    Environment = var.environment
  }
}

# Launch Template
resource "aws_launch_template" "this" {
  name_prefix   = "${var.app_name}-${var.environment}-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.this_web.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.app_name}-${var.environment}"
      Environment = var.environment
    }
  }
}

# ALB
resource "aws_lb" "this" {
  name               = "${var.app_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.this_alb.id]
  subnets            = var.subnet_ids

  tags = {
    Name        = "${var.app_name}-${var.environment}-alb"
    Environment = var.environment
  }
}

# Target Group
resource "aws_lb_target_group" "this" {
  name     = "${var.app_name}-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }

  tags = {
    Name        = "${var.app_name}-${var.environment}-tg"
    Environment = var.environment
  }
}

# Listener
resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# ASG
resource "aws_autoscaling_group" "this" {
  name                = "${var.app_name}-${var.environment}-asg"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = var.subnet_ids
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.this.arn]

  tag {
    key                 = "Name"
    value               = "${var.app_name}-${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}