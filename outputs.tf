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

output "ecr" {
  value = {
    repository_url = aws_ecr_repository.main.repository_url
  }
}


data "aws_caller_identity" "current" {}
output "account" {
  value = {
    account_id  = data.aws_caller_identity.current.account_id
    caller_arn  = data.aws_caller_identity.current.arn
    caller_user = data.aws_caller_identity.current.user_id
  }
}

output "fargate_lb" {
  value = {
    lb_dns_name  = module.ecs_fargate.lb_dns_name
    lb_zone_id   = module.ecs_fargate.lb_zone_id
    cluster_id   = module.ecs_fargate.cluster_id
    cluster_name = module.ecs_fargate.cluster_name
  }
}

output "route53_dns" {
  value = {
    www_name     = module.route53.www_name
    www_fqdn     = module.route53.www_fqdn
    non_www_name = module.route53.non_www_name
    non_www_fqdn = module.route53.non_www_fqdn
  }
}
