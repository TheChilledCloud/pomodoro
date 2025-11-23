# Defines ECS Service
resource "aws_ecs_service" "pomodoro" {
  name            = "pomodoro-service"
  cluster         = aws_ecs_cluster.pomodoro.id
  task_definition = aws_ecs_task_definition.pomodoro.arn
  desired_count   = 1 # Run 1 container
  launch_type     = "FARGATE"

  # where to run containers
  network_configuration {
    subnets = [
      aws_subnet.public_1.id, #usually has to be private subnets with NAT, currently using public for simplicity and avoid NAT costs
      aws_subnet.public_2.id
    ]
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true # Needed to pull image from ECR
  }

  # Connect to load balancer
  load_balancer {
    target_group_arn = aws_lb_target_group.pomodoro.arn
    container_name   = "pomodoro-app"
    container_port   = 80
  }

  deployment_maximum_percent         = 200 # Can temporarily have 2x containers during deployment
  deployment_minimum_healthy_percent = 50  # Must keep at least 50% running

  # Auto-restart if container crashes
  deployment_circuit_breaker {
    enable   = true
    rollback = true # Rollback if deployment fails
  }

  # Wait for load balancer to be ready
  depends_on = [
    aws_lb_listener.pomodoro,
    aws_iam_role_policy_attachment.ecs_task_execution_role_policy
  ]

  tags = {
    Name = "pomodoro-ecs-service"
  }
}


output "ecs_service_name" {
  value = aws_ecs_service.pomodoro.name
}

output "app_url" {
  description = "Access your app at this URL"
  value       = "http://${aws_lb.pomodoro.dns_name}"
}
