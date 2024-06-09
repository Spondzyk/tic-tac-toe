# security.tf

# ALB security Group: Edit to restrict access to the application
resource "aws_security_group" "lb" {
  name        = "cb-load-balancer-security-group"
  description = "controls access to the ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = var.container_port_frontend
    to_port     = var.container_port_frontend
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = var.container_port_backend
    to_port     = var.container_port_backend
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for the frontend application
resource "aws_security_group" "frontend" {
  name        = "cb-frontend-security-group"
  description = "allow inbound access from the ALB and ECS frontend"

  vpc_id = aws_vpc.main.id

  ingress {
    protocol        = "tcp"
    from_port       = var.container_port_frontend
    to_port         = var.container_port_frontend
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group for the backend application
resource "aws_security_group" "backend" {
  name        = "cb-backend-security-group"
  description = "allow inbound access from ECS frontend only"

  vpc_id = aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = var.container_port_backend
    to_port     = var.container_port_backend
    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}