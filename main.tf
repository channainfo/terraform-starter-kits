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
  name_prefix       = "/ecs/${local.ecs_ec2_app_name}"
  retention_in_days = 7

  tags = {
    "ecs_ec2_log" = "ec2 module"
  }
}

data "template_file" "ecs_ec2" {
  template = file("template/container_def.json.tpl")
  vars = merge(local.task_template_vars, {
    "app_mode"       = "web"
    "container_name" = local.ecs_ec2_app_name
    "log_group_name" = aws_cloudwatch_log_group.ec2.name
  })
}


module "ecs_ec2" {
  source                = "./modules/ecs_ec2"
  name                  = local.ecs_ec2_app_name
  task_cpu              = var.task_cpu
  task_memory           = var.task_memory
  image_id              = var.image_id
  instance_type         = var.instance_type
  vpc_id                = module.vpc.vpc_id
  security_group_ids    = [module.sg.ecs.id]
  subnet_ids            = module.vpc.public_subnet_ids
  key_name              = aws_key_pair.ec2.key_name
  max_count             = var.max_count
  min_count             = var.min_count
  desired_count         = var.desired_count
  container_cpu         = var.container_cpu
  container_memory      = var.container_memory
  container_port        = var.container_port
  iam_instance_profile  = module.iam_ecs.instance_profile_name
  execution_role_arn    = module.iam_ecs.execution_role_arn
  task_role_arn         = module.iam_ecs.task_role_arn
  container_definitions = data.template_file.ecs_ec2.rendered
  metric_type           = "CPU"
}



resource "aws_cloudwatch_log_group" "fargate" {
  name_prefix       = "/ecs/${local.ecs_fargate_app_name}"
  retention_in_days = 7

  tags = {
    "ecs_fargate_log" = "fargate module"
  }
}

data "template_file" "ecs_fargate" {
  template = file("template/container_def.json.tpl")
  vars = merge(local.task_template_vars, {
    "app_mode"       = "web"
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
}

module "route53" {
  source      = "./modules/route53"
  domain_name = var.domain_name
  lb_dns_name = module.ecs_fargate.lb_dns_name
  lb_zone_id  = module.ecs_fargate.lb_zone_id
}
