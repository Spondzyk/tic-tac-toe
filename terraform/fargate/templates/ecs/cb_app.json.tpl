[
  {
    "name": "backend",
    "image": "${backend_image}",
    "cpu": ${app_cpu},
    "memory": ${app_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/backend",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs-backend"
      }
    },
    "portMappings": [
      {
        "containerPort": ${backend_port},
        "hostPort": ${backend_port}
      }
    ]
  },
  {
    "name": "frontend",
    "image": "${frontend_image}",
    "cpu": ${app_cpu},
    "memory": ${app_memory},
    "networkMode": "awsvpc",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/frontend",
        "awslogs-region": "${aws_region}",
        "awslogs-stream-prefix": "ecs-frontend"
      }
    },
    "portMappings": [
      {
        "containerPort": ${frontend_port},
        "hostPort": ${frontend_port}
      }
    ]
  }
]