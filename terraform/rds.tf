# DB subnet group, defines where RDS can be deployed
resource "aws_db_subnet_group" "pomodoro" {
  name       = "pomodoro-db-subnet-group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "pomodoro-db-subnet-group"
  }
}

# Defining The Database Instance
resource "aws_db_instance" "default" {
  identifier           = "pomodoro-db"
  allocated_storage    = 20    # 20 GB (Minimum)
  storage_type         = "gp2" # General Purpose SSD
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro" # Free tier eligible
  db_name              = "pomodoro"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true  # Set to false for production!
  publicly_accessible  = false # Keep it secure inside VPC

  db_subnet_group_name   = aws_db_subnet_group.pomodoro.name
  vpc_security_group_ids = [aws_security_group.rds.id]
}

output "db_endpoint" {
  value = aws_db_instance.default.address
}
