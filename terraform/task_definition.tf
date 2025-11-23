# Task Definition
resource "aws_ecs_task_definition" "pomodoro" {
  family                   = "pomodoro-task"
  network_mode             = "awsvpc" # Required for Fargate
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256" # 0.25 vCPU
  memory                   = "512" # 512 MB
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "pomodoro-app"
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.us-east-1.amazonaws.com/pomodoro-ecr:latest"
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "FLASK_APP"
          value = "app.py"
        },
        {
          name  = "FLASK_ENV"
          value = "production"
        },
        {
          name  = "FLASK_DEBUG"
          value = "False"
        },
        {
          name  = "BIND_PORT"
          value = "80"
        },
        {
          name  = "SECRET_KEY"
          value = var.task_secret_key # TODO: Move to Secrets Manager
        },
        {
          name  = "DATABASE_URL"
          value = "mysql+pymysql://${var.db_username}:${var.db_password}@${aws_db_instance.default.address}:3306/pomodoro"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = "us-east-1"
          "awslogs-stream-prefix" = "pomodoro-app"
        }
      }

      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:80 || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }
    }
  ])

  tags = {
    Name = "pomodoro-task-definition"
  }
}

# Get current AWS account ID for ECR image URL
data "aws_caller_identity" "current" {}

output "task_definition_arn" {
  value = aws_ecs_task_definition.pomodoro.arn
}
