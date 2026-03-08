output "rds_subnet_group_name" {
  description = "RDS subnet group name for Crossplane claims"
  value       = aws_db_subnet_group.rds.name
}

output "rds_security_group_id" {
  description = "RDS security group ID for Crossplane claims"
  value       = aws_security_group.rds.id
}

output "tailscale_router_instance_id" {
  value = module.tailscale_router.router_instance_id
}

output "tailscale_router_private_ip" {
  value = module.tailscale_router.router_private_ip
}

output "tailscale_router_public_ip" {
  value = module.tailscale_router.router_public_ip
}

output "tailscale_router_security_group_id" {
  value = module.tailscale_router.router_security_group_id
}

output "private_hosted_zone_id" {
  value = aws_route53_zone.private.zone_id
}