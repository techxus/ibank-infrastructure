############################################
# modules/aws/eks/variables.tf
# Purpose:
# - This file DECLARES inputs the EKS module accepts.
# - Think of this like a Java method signature:
#     createEks(region, env, vpcId, privateSubnets, ...)
#
# Student notes:
# - A variable block is like a "parameter".
# - Values come from the environment root module (envs/...),
#   usually via terraform.tfvars or explicit arguments in main.tf.
# - IMPORTANT HCL RULE:
#   If you define more than ONE property (type, default, description),
#   you MUST use multi-line syntax.
############################################

############################################
# Basic inputs
############################################
variable "env" {
  description = "Environment name (dev, stage, prod)"
  type        = string
}

############################################
# Cluster naming + version
############################################
variable "cluster_name" {
  description = "Full EKS cluster name"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for EKS control plane"
  type        = string
}

############################################
# Networking inputs (usually come from networking workspace)
############################################
variable "vpc_id" {
  description = "VPC ID where EKS will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs where EKS worker nodes will run"
  type        = list(string)
}

############################################
# EKS API endpoint access (public vs private)
############################################
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

############################################
# Worker node sizing
############################################
variable "node_instance_type" {
  description = "EC2 instance type for worker nodes (example: t3.small)"
  type        = string
  default     = "t3.small"
}

############################################
# Node Group 1 scaling
############################################
variable "ng1_name" {
  description = "Node group 1's name (used for tagging and IRSA)'"
  type        = string
  default     = "node-group-1"
}
variable "ng1_min_size" {
  description = "Node group 1: minimum number of nodes"
  type        = number
  default     = 1
}

variable "ng1_max_size" {
  description = "Node group 1: maximum number of nodes"
  type        = number
  default     = 3
}

variable "ng1_desired_size" {
  description = "Node group 1: desired number of nodes"
  type        = number
  default     = 2
}

############################################
# Node Group 2 scaling
############################################
variable "ng2_name" {
  description = "Node group 2's name (used for tagging and IRSA)'"
  type        = string
  default     = "node-group-2"
}

variable "ng2_min_size" {
  description = "Node group 2: minimum number of nodes"
  type        = number
  default     = 1
}

variable "ng2_max_size" {
  description = "Node group 2: maximum number of nodes"
  type        = number
  default     = 2
}

variable "ng2_desired_size" {
  description = "Node group 2: desired number of nodes"
  type        = number
  default     = 1
}

############################################
# Tags
############################################
variable "tags" {
  description = "Extra AWS tags to apply to created resources"
  type        = map(string)
  default     = {}
}

variable "ami_type" {
  description = "EKS managed node group AMI type"
  type        = string
  default     = "AL2_x86_64"
}