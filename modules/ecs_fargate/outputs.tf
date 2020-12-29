output "lb_dns_name" {
  value = aws_lb.main.dns_name
}

output "lb_zone_id" {
  value = aws_lb.main.zone_id
}
output "cluster_id" {
  value = aws_ecs_cluster.main.id
}
output "cluster_name" {
  value = aws_ecs_cluster.main.name
}
