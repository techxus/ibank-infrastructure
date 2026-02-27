variable "region" {
  description = "AWS region"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "domain" {
  description = "Root domain name"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}