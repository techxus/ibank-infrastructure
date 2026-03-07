variable "env" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "tailscale_auth_key" {
  description = "Tailscale tagged auth key"
  type        = string
  sensitive   = true
}

variable "advertise_routes" {
  description = "Routes advertised to tailnet"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for subnet router"
  type        = string
  default     = "t3.micro"
}