# Defines Task Execution Role, lets ECS pull image from ECR and write logs
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "pomodoro-ecs-task-execution-role"

  # Trust policy = Who can USE this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "pomodoro-ecs-task-execution-role"
  }
}

# Attach AWS managed policy to task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# Defining Task Role, which is what the app use to access other AWS services
resource "aws_iam_role" "ecs_task_role" {
  name = "pomodoro-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "pomodoro-ecs-task-role"
  }
}

# Outputs for use in task definition
output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  value = aws_iam_role.ecs_task_role.arn
}
