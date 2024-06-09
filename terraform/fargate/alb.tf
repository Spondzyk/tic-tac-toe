# alb.tf

resource "aws_alb" "main" {
  name        = "cb-load-balancer"
  subnets         = aws_subnet.public.*.id
  security_groups = [aws_security_group.lb.id]
}

# Frontend target group
resource "aws_alb_target_group" "frontend" {
  name        = "frontend-target-group"
  port        = var.container_port_frontend
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  deregistration_delay = "30"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}

# Backend target group
resource "aws_alb_target_group" "backend" {
  name        = "backend-target-group"
  port        = var.container_port_backend
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  deregistration_delay = "30"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}

# Listener for frontend
resource "aws_alb_listener" "frontend" {
  load_balancer_arn = aws_alb.main.id
  port              = var.container_port_frontend
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.frontend.id
    type             = "forward"
  }
}

# Listener for backend
resource "aws_alb_listener" "backend" {
  load_balancer_arn = aws_alb.main.id
  port              = var.container_port_backend
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.backend.id
    type             = "forward"
  }
}