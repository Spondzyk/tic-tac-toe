# Backend log group
resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/backend"
  retention_in_days = 30

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "backend-log-group"
  }
}

# Frontend log group
resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/frontend"
  retention_in_days = 30

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "frontend-log-group"
  }
}