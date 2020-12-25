output "vpc" {
  value = {
    id                 = module.vpc.vpc_id
    cidr               = module.vpc.vpc_cidr
    az_names           = module.vpc.az_names
    private_subnet_ids = module.vpc.private_subnet_ids
    public_subnet_ids  = module.vpc.public_subnet_ids
  }
}

output "sg" {
  value = {
    bastion       = module.sg.bastion.id
    webserver     = module.sg.webserver.id
    mysql         = module.sg.mysql.id
    postgresql    = module.sg.postgresql.id
    redis         = module.sg.redis.id
    memcached     = module.sg.memcached.id
    load_balancer = module.sg.load_balancer.id
    ecs           = module.sg.ecs.id
  }
}
output "rds" {
  value = {
    postgresql = {
      address                    = module.rds.postgresql_address
      postgresql_engine_versions = module.rds.postgresql_engine_versions
      engine_version             = module.rds.postgresql_engine_version
    }
  }
}
