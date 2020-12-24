output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

output "az_names" {
  value = local.az_names
}

output "public_subnet_ids" {
  value = aws_subnet.publics.*.id
}


output "private_subnet_ids" {
  value = aws_subnet.privates.*.id
}
