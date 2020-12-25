data "aws_rds_engine_version" "postgresql" {
  engine = "postgres"
}

resource "aws_db_subnet_group" "main" {
  name_prefix = "main"
  subnet_ids  = var.subnet_ids

  tags = {
    Name = "RDS subnet group"
  }
}

resource "aws_kms_key" "insight_key" {
  description = "KMS key for RDS performance insight"
  is_enabled  = true

  tags = {
    Name = "KMSKEY postgresqlInsight"
  }
}

resource "aws_db_instance" "postgresql" {
  identifier        = "${var.identifier}-postgresql"
  allocated_storage = 20
  storage_type      = "gp2"
  engine            = "postgres"
  engine_version    = local.postgresql_engine_version
  instance_class    = var.postgresql_engine_class
  storage_encrypted = false

  multi_az = true

  name     = var.postgresql_db_name
  username = var.postgresql_db_username
  password = var.postgresql_db_password

  backup_retention_period = 7

  db_subnet_group_name = aws_db_subnet_group.main.name
  deletion_protection  = true

  enabled_cloudwatch_logs_exports = ["postgresql"]

  performance_insights_kms_key_id       = aws_kms_key.insight_key.arn
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  vpc_security_group_ids = var.security_group_ids

  final_snapshot_identifier = "${var.identifier}-postgresql"
  skip_final_snapshot       = false
  # Storage auto scaling
  max_allocated_storage = 200
}
