output "router_instance_id" {
  value = aws_instance.router.id
}

output "router_private_ip" {
  value = aws_instance.router.private_ip
}

output "router_public_ip" {
  value = aws_instance.router.public_ip
}

output "router_security_group_id" {
  value = aws_security_group.router.id
}