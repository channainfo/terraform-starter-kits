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

module "s3_storage" {
  source      = "./modules/s3"
  bucket_name = var.s3_storage.bucket_name
  sites       = local.s3_cors_sites
}

module "s3_storage_dev" {
  source      = "./modules/s3"
  bucket_name = "${var.s3_storage.bucket_name}-dev"
  sites       = local.s3_cors_sites
}

module "s3_storage_staging" {
  source      = "./modules/s3"
  bucket_name = "${var.s3_storage.bucket_name}-staging"
  sites       = local.s3_cors_sites
}

# EC2 instance access key name
resource "aws_ecr_repository" "main" {
  name                 = lower(var.name)
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_key_pair" "ec2" {
  key_name   = var.name
  public_key = file(var.ssh_public_key_file)
}

module "iam_ecs" {
  source = "./modules/ecs_role"
  name   = lower(var.name)
}

resource "aws_cloudwatch_log_group" "ec2" {
  name_prefix       = "/ecs/vtenh-ec2"
  retention_in_days = 7

  tags = {
    "ecs_ec2_log" = "ec2 module"
  }
}

data "template_file" "ecs_ec2" {
  template = file("template/container_def.json.tpl")
  vars = merge(local.web_container_template_vars, {
    "container_name" = local.ecs_ec2_app_name
    "log_group_name" = aws_cloudwatch_log_group.ec2.name
  })
}


# module "ecs_ec2" {
#   source                = "./modules/ecs_ec2"
#   name                  = local.ecs_ec2_app_name
#   task_cpu              = var.task_cpu
#   task_memory           = var.task_memory
#   image_id              = var.image_id
#   instance_type         = var.instance_type
#   vpc_id                = module.vpc.vpc_id
#   security_group_ids    = [module.sg.ecs.id]
#   subnet_ids            = module.vpc.public_subnet_ids
#   key_name              = aws_key_pair.ec2.key_name
#   max_count             = var.max_count
#   min_count             = var.min_count
#   desired_count         = var.desired_count
#   container_cpu         = var.container_cpu
#   container_memory      = var.container_memory
#   container_port        = var.container_port
#   iam_instance_profile  = module.iam_ecs.instance_profile_name
#   execution_role_arn    = module.iam_ecs.execution_role_arn
#   task_role_arn         = module.iam_ecs.task_role_arn
#   container_definitions = data.template_file.ecs_ec2.rendered
#   metric_type           = "CPU"
# }

resource "aws_cloudwatch_log_group" "fargate" {
  name              = "/ecs/vtenh-web"
  retention_in_days = 7

  tags = {
    "ecs_fargate_log" = "fargate"
  }
}

data "template_file" "ecs_fargate" {
  template = file("template/container_def.json.tpl")
  vars = merge(local.web_container_template_vars, {
    "container_name" = local.ecs_fargate_app_name
    "log_group_name" = aws_cloudwatch_log_group.fargate.name
  })
}

module "ecs_fargate" {
  source                = "./modules/ecs_fargate"
  name                  = local.ecs_fargate_app_name
  container_name        = local.ecs_fargate_app_name
  security_group_ids    = [module.sg.ecs.id]
  subnet_ids            = module.vpc.public_subnet_ids
  vpc_id                = module.vpc.vpc_id
  health_check_path     = var.health_check_path
  cpu                   = var.task_cpu
  memory                = var.task_memory
  desired_count         = var.desired_count
  max_count             = var.max_count
  min_count             = var.min_count
  container_definitions = data.template_file.ecs_fargate.rendered
  container_port        = var.container_port
  execution_role_arn    = module.iam_ecs.execution_role_arn
  task_role_arn         = module.iam_ecs.task_role_arn
  acm_certificate_arn   = var.acm_certificate_arn
  metric_type           = "CPU"
  domain_name           = var.domain_name
}

module "route53" {
  source      = "./modules/route53"
  domain_name = var.domain_name
  lb_dns_name = module.ecs_fargate.lb_dns_name
  lb_zone_id  = module.ecs_fargate.lb_zone_id
}


################################### Sitemap
resource "aws_cloudwatch_log_group" "sitemap" {
  name_prefix       = "/ecs/sitemap"
  retention_in_days = 7

  tags = {
    "ecs_schedule_task_log" = "sitemap"
  }
}
data "template_file" "sitemap" {
  template = file("template/container_def.json.tpl")

  # custom command with sitemap
  vars = merge(local.scheduled_task_container_template_vars, {
    "rails_task_name" = "sitemap:refresh"
    "container_name"  = local.ecs_fargate_sitemap
    "log_group_name"  = aws_cloudwatch_log_group.sitemap.name
  })
}

module "ecs_scheduele_sitemap" {
  source                    = "./modules/ecs_scheduled_task"
  name                      = local.ecs_fargate_sitemap
  container_definitions     = data.template_file.sitemap.rendered
  execution_role_arn        = module.iam_ecs.execution_role_arn
  task_role_arn             = module.iam_ecs.task_role_arn
  cpu                       = var.task_cpu
  memory                    = var.task_memory
  security_group_ids        = [module.sg.ecs.id]
  subnet_ids                = module.vpc.public_subnet_ids
  is_scheduled_task         = true
  schedule_expression_start = "cron(0 17 * * ? *)"
  schedule_expression_stop  = "cron(20 17 * * * ? *)"
}


################################### Migration
resource "aws_cloudwatch_log_group" "migration" {
  name_prefix       = "/ecs/migration"
  retention_in_days = 7

  tags = {
    "ecs_schedule_task_log" = "migration"
  }
}
data "template_file" "db_migration" {
  template = file("template/container_def.json.tpl")

  # custom command with db_migration
  vars = merge(local.scheduled_task_container_template_vars, {
    "rails_task_name" = "db:migrate"
    "container_name"  = local.ecs_fargate_db_migration
    "log_group_name"  = aws_cloudwatch_log_group.migration.name
  })
}

module "ecs_scheduele_db_migration" {
  source                    = "./modules/ecs_scheduled_task"
  name                      = local.ecs_fargate_db_migration
  container_definitions     = data.template_file.db_migration.rendered
  execution_role_arn        = module.iam_ecs.execution_role_arn
  task_role_arn             = module.iam_ecs.task_role_arn
  cpu                       = var.task_cpu
  memory                    = var.task_memory
  security_group_ids        = [module.sg.ecs.id]
  subnet_ids                = module.vpc.public_subnet_ids
  is_scheduled_task         = false
  schedule_expression_start = "cron(0 17 * * ? *)"
}

module "run_migration" {
  source             = "./modules/ecs_one_off_task"
  ecs_cluster_name   = module.ecs_fargate.cluster_name
  task_arn           = module.ecs_scheduele_db_migration.task_arn
  security_group_ids = [module.sg.ecs.id]
  subnet_ids         = module.vpc.public_subnet_ids
  profile            = var.aws.config.profile
  region             = var.aws.credentials.region

}
