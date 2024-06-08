variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-1"
}

variable "health_check_path" {
  description = "Path for health checks"
  default     = "/"
}

variable "ec2_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "myEcsTaskExecutionRole"
}

variable "ecs_auto_scale_role_name" {
  description = "ECS auto scale role name"
  default     = "myEcsAutoScaleRole"
}

data "aws_iam_role" "ecs_task_execution_role" {
  name = "labRole"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = 2
}

variable "container_count" {
  description = "Number of Docker containers to run for both frontend and backend"
  default     = 1
}

variable "container_image_backend" {
  description = "Docker image to run for the backend in the ECS cluster"
  default     = "spondzyk/tic-tac-toe-app-server:latest"
}

variable "container_image_frontend" {
  description = "Docker image to run for the frontend in the ECS cluster"
  default     = "spondzyk/tic-tac-toe-app-client:latest"
}

variable "container_port_backend" {
  description = "Port exposed by the backend Docker image to redirect traffic to"
  default     = 3000
}

variable "container_port_frontend" {
  description = "Port exposed by the frontend Docker image to redirect traffic to"
  default     = 8080
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  type        = number
  default     = 1024
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  type        = number
  default     = 2048
}