locals {

  postgresql_engine_versions            = data.aws_rds_engine_version.postgresql.*.version
  most_recent_postgresql_engine_version = element(local.postgresql_engine_versions, length(local.postgresql_engine_versions) - 1)

  postgresql_engine_version = var.postgresql_engine_version != "" ? var.postgresql_engine_version : local.most_recent_postgresql_engine_version

}
