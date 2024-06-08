# logs.tf

# Backend log group
resource "aws_cloudwatch_log_group" "backend_log_group" {
  name              = "/ecs/backend"
  retention_in_days = 30

  tags = {
    Name = "cb-backend-log-group"
  }
}

# Frontend log group
resource "aws_cloudwatch_log_group" "frontend_log_group" {
  name              = "/ecs/frontend"
  retention_in_days = 30

  tags = {
    Name = "cb-frontend-log-group"
  }
}
