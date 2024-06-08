# auto_scaling.tf

resource "aws_appautoscaling_target" "backend_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/backend-service"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = data.aws_iam_role.ecs_task_execution_role.arn
  min_capacity       = 1
  max_capacity       = 5

  depends_on = [aws_ecs_service.backend]  # Ensure proper dependency
}

resource "aws_appautoscaling_target" "frontend_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/frontend-service"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = data.aws_iam_role.ecs_task_execution_role.arn
  min_capacity       = 1
  max_capacity       = 5

  depends_on = [aws_ecs_service.frontend]  # Ensure proper dependency
}

# Backend autoscaling policies
resource "aws_appautoscaling_policy" "backend_scale_up" {
  name               = "cb_backend_scale_up"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/backend-service"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.backend_target]
}

resource "aws_appautoscaling_policy" "backend_scale_down" {
  name               = "cb_backend_scale_down"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/backend-service"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.backend_target]
}

# Frontend autoscaling policies
resource "aws_appautoscaling_policy" "frontend_scale_up" {
  name               = "cb_frontend_scale_up"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/frontend-service"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.frontend_target]
}

resource "aws_appautoscaling_policy" "frontend_scale_down" {
  name               = "cb_frontend_scale_down"
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/frontend-service"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.frontend_target]
}

# CloudWatch alarm for backend
resource "aws_cloudwatch_metric_alarm" "backend_cpu_high" {
  alarm_name          = "cb_backend_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "85"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = "backend-service"
  }

  alarm_actions = [aws_appautoscaling_policy.backend_scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "backend_cpu_low" {
  alarm_name          = "cb_backend_cpu_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = "backend-service"
  }

  alarm_actions = [aws_appautoscaling_policy.backend_scale_down.arn]
}

# CloudWatch alarm for frontend
resource "aws_cloudwatch_metric_alarm" "frontend_cpu_high" {
  alarm_name          = "cb_frontend_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "85"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = "frontend-service"
  }

  alarm_actions = [aws_appautoscaling_policy.frontend_scale_up.arn]
}

resource "aws_cloudwatch_metric_alarm" "frontend_cpu_low" {
  alarm_name          = "cb_frontend_cpu_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = "frontend-service"
  }

  alarm_actions = [aws_appautoscaling_policy.frontend_scale_down.arn]
}