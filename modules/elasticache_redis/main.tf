resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.identifier}-sng"
  subnet_ids = var.subnet_ids
}

resource "aws_elasticache_cluster" "main" {
  cluster_id           = var.identifier
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = 1
  parameter_group_name = var.parameter_group_name
  engine_version       = var.engine_version
  port                 = 6379
  security_group_ids   = var.security_group_ids
  subnet_group_name    = aws_elasticache_subnet_group.main.name

  tags = {
    "redis" = "Terraform"
  }
}
