output "lb_dns_name" {
  value = aws_lb.main.dns_name
}
output "cluster_id" {
  value = aws_ecs_cluster.main.id
}
output "cluster_name" {
  value = aws_ecs_cluster.main.name
}
