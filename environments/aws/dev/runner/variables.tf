variable "region" {
  description = "AWS region"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for runner"
  type        = string
  default     = "t3.medium"
}

variable "runner_count" {
  description = "Number of runner instances"
  type        = number
  default     = 1
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "github_repo_infra" {
  description = "Infrastructure repo name"
  type        = string
  default     = "ibank-infrastructure"
}

variable "github_repo_platform" {
  description = "Platform repo name"
  type        = string
  default     = "ibank-platform"
}