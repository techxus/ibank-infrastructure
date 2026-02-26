############################################
# ecr.tf
# One repo per microservice, shared across
# all environments (dev/stage/prod)
############################################

resource "aws_ecr_repository" "services" {
  for_each = toset(var.service_names)

  name                 = "ibank/${each.key}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge({ ManagedBy = "Terraform" }, var.tags)
}

resource "aws_ecr_lifecycle_policy" "services" {
  for_each   = aws_ecr_repository.services
  repository = each.value.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }]
  })
}