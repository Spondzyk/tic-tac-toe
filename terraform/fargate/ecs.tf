# ecs.tf

resource "aws_ecs_cluster" "main" {
  name = "cluster"
}

data "template_file" "cb_app" {
  template = file("./templates/ecs/cb_app.json.tpl")

  vars = {
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
    aws_region     = var.aws_region
    app_cpu        = var.fargate_cpu
    app_memory     = var.fargate_memory
    backend_image  = var.container_image_backend
    backend_port   = var.container_port_backend
    frontend_image = var.container_image_frontend
    frontend_port  = var.container_port_frontend
  }
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-task"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = jsonencode([
    {
      name         = "frontend-app"
      image        = var.container_image_frontend
      cpu          = var.fargate_cpu
      memory       = var.fargate_memory
      essential    = true
      portMappings = [
        {
          containerPort = var.container_port_frontend
          hostPort      = var.container_port_frontend
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "backend-task"
  execution_role_arn       = data.aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = jsonencode([
    {
      name         = "backend-app"
      image        = var.container_image_backend
      cpu          = var.fargate_cpu
      memory       = var.fargate_memory
      essential    = true
      portMappings = [
        {
          containerPort = var.container_port_backend
          hostPort      = var.container_port_backend
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "FRONTEND_URL"
          value = aws_alb.main.dns_name
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "frontend" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = var.container_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.lb.id]
    subnets          = [aws_subnet.private[0].id] # Use the first private subnet
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.frontend.id
    container_name   = "frontend-app"
    container_port   = var.container_port_frontend
  }

  depends_on = [aws_alb_listener.frontend]
}

resource "aws_ecs_service" "backend" {
  name            = "backend-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.container_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.lb.id]
    subnets          = [aws_subnet.private[0].id] # Use the first private subnet
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.backend.id
    container_name   = "backend-app"
    container_port   = var.container_port_backend
  }

  depends_on = [aws_alb_listener.backend]
}
