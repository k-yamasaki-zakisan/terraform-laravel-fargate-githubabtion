resource "aws_ecr_repository" "default" {
  name                 = local.APP_NAME
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}