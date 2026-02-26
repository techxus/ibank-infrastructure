############################################
# modules/aws/vpc/variables.tf
############################################

variable "region" {
  description = "AWS region (example: us-east-1)"
  type        = string
}

variable "env" {
  description = "Environment name (dev, stage, prod)"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (example: 10.0.0.0/16)"
  type        = string
}

variable "az_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 2
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway for all AZs (cheaper, less resilient)"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Extra AWS tags to apply to all resources"
  type        = map(string)
  default     = {}
}