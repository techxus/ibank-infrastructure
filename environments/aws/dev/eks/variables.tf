############################################
# environments/aws/dev/eks/variables.tf
############################################

variable "region" {
  description = "AWS region"
  type        = string
}

variable "env" {
  description = "Environment name (dev/stage/prod)"
  type        = string
}

variable "cluster_name_prefix" {
  description = "Prefix for the EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS control plane"
  type        = string
}

variable "cluster_endpoint_public_access" {
  description = "If true, EKS API endpoint is reachable from the internet"
  type        = bool
  default     = false
}

variable "cluster_endpoint_private_access" {
  description = "If true, EKS API endpoint is reachable from inside the VPC"
  type        = bool
  default     = true
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.small"
}

variable "ng1_min_size" {
  description = "Node group 1 minimum nodes"
  type        = number
  default     = 1
}

variable "ng1_max_size" {
  description = "Node group 1 maximum nodes"
  type        = number
  default     = 3
}

variable "ng1_desired_size" {
  description = "Node group 1 desired nodes"
  type        = number
  default     = 2
}

variable "ng2_min_size" {
  description = "Node group 2 minimum nodes"
  type        = number
  default     = 1
}

variable "ng2_max_size" {
  description = "Node group 2 maximum nodes"
  type        = number
  default     = 2
}

variable "ng2_desired_size" {
  description = "Node group 2 desired nodes"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vpc_id" {
  description = "VPC ID from vpc workspace"
  type        = string
  default     = "vpc-mock"    # ← add default for destroy
}

variable "private_subnet_ids" {
  description = "Private subnet IDs from vpc workspace"
  type        = list(string)
  default     = ["subnet-mock-1", "subnet-mock-2"]   # ← add default for destroy
}