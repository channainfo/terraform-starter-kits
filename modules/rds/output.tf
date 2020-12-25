output "postgresql_address" {
  value = aws_db_instance.postgresql.address
}

output "postgresql_engine_versions" {
  value = local.postgresql_engine_versions
}

output "postgresql_engine_version" {
  value = local.postgresql_engine_version
}
