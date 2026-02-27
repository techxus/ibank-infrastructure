output "rds_subnet_group_name" {
  description = "RDS subnet group name for Crossplane claims"
  value       = aws_db_subnet_group.rds.name
}

output "rds_security_group_id" {
  description = "RDS security group ID for Crossplane claims"
  value       = aws_security_group.rds.id
}