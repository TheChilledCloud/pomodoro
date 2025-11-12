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