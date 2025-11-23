# Defines security Group for Load Balancer
resource "aws_security_group" "alb" {
  name        = "pomodoro-alb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.pomodoro_vpc.id

  # Ingress (inbound)
  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Anyone on internet
  }

  # Egress (outbound)
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pomodoro-alb-sg"
  }
}

# Defines security Group for ECS Tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "pomodoro-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.pomodoro_vpc.id

  # Only accept traffic FROM load balancer
  ingress {
    description     = "Allow traffic from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id] # Only from ALB!
  }

  # Allow all outbound (to reach internet, databases, etc)
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pomodoro-ecs-tasks-sg"
  }
}

# Defines security Group for RDS. Only allows traffic from the ECS Tasks
resource "aws_security_group" "rds" {
  name        = "pomodoro-rds-sg"
  description = "Allow inbound traffic from ECS tasks"
  vpc_id      = aws_vpc.pomodoro_vpc.id

  ingress {
    description     = "Allow MySQL from ECS"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id] # Only ECS can enter
  }

  tags = {
    Name = "pomodoro-rds-sg"
  }
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs_tasks.id
}
