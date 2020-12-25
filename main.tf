module "vpc" {
  source = "./modules/vpc"

  name   = var.name
  region = var.aws.credentials.region

  default_tags = local.default_tags
}

module "sg" {
  source   = "./modules/security_group"
  vpc_id   = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr

  default_tags = local.default_tags
}

module "rds" {
  source                    = "./modules/rds"
  identifier                = "db"
  postgresql_engine_class   = var.rds.postgresql.engine_class
  postgresql_engine_version = var.rds.postgresql.engine_version
  postgresql_db_name        = var.rds.postgresql.db_name
  postgresql_db_username    = var.rds.postgresql.db_username
  postgresql_db_password    = var.rds.postgresql.db_password
  subnet_ids                = module.vpc.private_subnet_ids
  security_group_ids        = [module.sg.postgresql.id]

}
