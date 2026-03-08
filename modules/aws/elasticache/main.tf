resource "aws_security_group" "redis" {
  name        = "${var.name}-redis"
  description = "Redis access from EKS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis from EKS nodes"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [var.eks_node_sg]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.name}-redis"
  subnet_ids = var.private_subnets
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id = "${var.name}-redis"

  engine               = "redis"
  engine_version       = "7.1"
  node_type            = "cache.t4g.small"

  num_cache_clusters   = 1

  port                 = 6379
  parameter_group_name = "default.redis7"

  subnet_group_name    = aws_elasticache_subnet_group.redis.name
  security_group_ids   = [aws_security_group.redis.id]

  automatic_failover_enabled = false

  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
}