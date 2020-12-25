locals {
  default_tags = {
    AutoManaged = "true"
    Generator   = var.name
  }

  ecs_ec2_app_name = "${var.name}-ec2"
  docker_image_url = aws_ecr_repository.main.repository_url

  ecs_ec2_log_group_name = aws_cloudwatch_log_group.ec2.name

  task_template_vars = merge(var.app_environments, {
    app_name         = "VTenh"
    bucket_Name      = var.s3_storage.bucket_name
    docker_image_url = local.docker_image_url
    container_name   = local.ecs_ec2_app_name
    log_group_name   = local.ecs_ec2_log_group_name


    container_cpu    = var.container_cpu
    container_memory = var.container_memory
    container_port   = var.container_port
    region           = var.aws.credentials.region
    rds_db_host      = module.rds.postgresql_address
    rds_db_name      = var.rds.postgresql.db_name
    rds_db_user      = var.rds.postgresql.db_username
    rds_db_password  = var.rds.postgresql.db_password
  })

}
