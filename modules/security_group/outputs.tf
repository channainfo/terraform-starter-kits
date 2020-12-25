output "bastion" {
  value = aws_security_group.bastion
}

output "webserver" {
  value = aws_security_group.webserver
}

output "mysql" {
  value = aws_security_group.mysql
}

output "postgresql" {
  value = aws_security_group.postgresql
}

output "redis" {
  value = aws_security_group.redis
}

output "memcached" {
  value = aws_security_group.memcached
}

output "load_balancer" {
  value = aws_security_group.load_balancer
}

output "ecs" {
  value = aws_security_group.ecs
}
