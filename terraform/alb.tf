# Application Load Balancer (ALB) to route traffic to ECS tasks
resource "aws_lb" "pomodoro" {
  name               = "pomodoro-alb"
  internal           = false # Public-facing (not internal)
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets = [
    aws_subnet.public_1.id,
    aws_subnet.public_2.id
  ]

  enable_deletion_protection = false

  tags = {
    Name = "pomodoro-alb"
  }
}

# which containers to send traffic to
resource "aws_lb_target_group" "pomodoro" {
  name        = "pomodoro-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.pomodoro_vpc.id
  target_type = "ip" # For Fargate, we use IP mode, cuz containers get dynamic IPs

  health_check {
    enabled             = true
    healthy_threshold   = 2     # 2 successful checks = healthy
    unhealthy_threshold = 3     # 3 failed checks = unhealthy
    timeout             = 5     # Wait 5 seconds for response
    interval            = 30    # Check every 30 seconds
    path                = "/"   # Check homepage
    matcher             = "200" # Expect HTTP 200 OK
  }

  tags = {
    Name = "pomodoro-target-group"
  }
}

# listens for incoming requests
resource "aws_lb_listener" "pomodoro" {
  load_balancer_arn = aws_lb.pomodoro.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.pomodoro.arn
  }
}

# Output the ALB URL 
output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.pomodoro.dns_name
}

output "alb_url" {
  description = "Full URL to access your app"
  value       = "http://${aws_lb.pomodoro.dns_name}"
}

output "target_group_arn" {
  description = "ARN of target group for ECS service"
  value       = aws_lb_target_group.pomodoro.arn
}
