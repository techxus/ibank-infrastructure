############################################
# global/ecr/main.tf
# Purpose:
# - Create one ECR repository per microservice.
# - All environments (dev, stage, prod) push/pull
#   from the same repos using different image tags.
############################################

resource "aws_ecr_repository" "services" {
  for_each = toset(var.service_names)

  name                 = "ibank/${each.key}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true             # Scans for CVEs on every push
  }

  tags = merge(
    {
      ManagedBy = "Terraform"
      Project   = "iBank"
    },
    var.tags
  )
}

############################################
# Lifecycle policy — keep last 10 images per repo
# Prevents unbounded storage growth
############################################

resource "aws_ecr_lifecycle_policy" "services" {
  for_each   = aws_ecr_repository.services
  repository = each.value.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}