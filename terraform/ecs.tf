# Defines ECS Cluster
resource "aws_ecs_cluster" "pomodoro" {
  name = "pomodoro-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "pomodoro-cluster"
  }
}


resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/pomodoro"
  retention_in_days = 7

  tags = {
    Name = "pomodoro-ecs-logs"
  }
}


output "ecs_cluster_name" {
  description = "ECS Cluster Name"
  value       = aws_ecs_cluster.pomodoro.name
}

output "ecs_cluster_arn" {
  description = "ECS Cluster ARN"
  value       = aws_ecs_cluster.pomodoro.arn
}
