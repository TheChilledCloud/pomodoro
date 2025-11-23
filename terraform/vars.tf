variable "region" {
  description = "Region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "ecr_name" {
  description = "Name of the ECR repo"
  type        = string
  default     = "pomodoro-ecr"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "pomodoro"
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "task_secret_key" {
  description = "Secret key for the Flask application"
  type = string
  sensitive = true
}
