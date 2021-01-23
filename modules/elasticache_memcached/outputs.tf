output "cluster_address" {
  value = aws_elasticache_cluster.main.cluster_address
}

output "configuration_endpoint" {
  value = aws_elasticache_cluster.main.configuration_endpoint
}
