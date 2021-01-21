output "cluster_address" {
  value = aws_elasticache_cluster.main.cache_nodes.0.address
}

output "cluster_port" {
  value = aws_elasticache_cluster.main.cache_nodes.0.port
}
