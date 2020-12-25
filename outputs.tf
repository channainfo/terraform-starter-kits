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
    bastion       = module.sg.bastion
    webserver     = module.sg.webserver
    mysql         = module.sg.mysql
    postgresql    = module.sg.postgresql
    redis         = module.sg.redis
    memcached     = module.sg.memcached
    load_balancer = module.sg.load_balancer
    ecs           = module.sg.ecs
  }
}
