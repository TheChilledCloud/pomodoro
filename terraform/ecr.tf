resource "aws_ecr_repository" "poomodoro_ecr_resource_name" {
  name                 = var.ecr_name
  image_tag_mutability = "MUTABLE" # or "IMMUTABLE" based on your requirement
  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.poomodoro_ecr_resource_name.repository_url
}