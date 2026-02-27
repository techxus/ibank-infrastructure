variable "region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
  default     = "techxus"
}

variable "github_repo" {
  description = "GitHub repository name"
  type        = string
  default     = "ibank-infrastructure"
}