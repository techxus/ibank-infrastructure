variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "service_names" {
  description = "List of microservice names — one ECR repo created per service"
  type        = list(string)
  default = [
    "ibank-user-service",
    "ibank-payment-service",
    "ibank-notification-service",
    "ibank-gateway-service"
  ]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}