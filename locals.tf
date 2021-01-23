locals {
  default_tags = {
    AutoManaged = "true"
    Generator   = var.name
  }

  custom_task_command = "\"command\": [ \"/tmp/custom_script/task.sh\" ],"

  s3_cors_sites = ["https://${var.domain_name}", "https://www.${var.domain_name}"]

  ecs_ec2_app_name         = "${var.name}-ec2"
  ecs_fargate_app_name     = "${var.name}-fargate"
  ecs_fargate_sitemap      = "${var.name}-sitemap"
  ecs_fargate_db_migration = "${var.name}-db-migration"
  ecs_queue_name           = "${var.name}-queue"

  docker_image_url = aws_ecr_repository.main.repository_url
  redis_url        = "redis://${module.redis.cluster_address}:${module.redis.cluster_port}/1"

  container_template_vars = merge(var.app_environments, {
    app_name         = "VTenh"
    bucket_Name      = var.s3_storage.bucket_name
    docker_image_url = local.docker_image_url

    custom_command  = ""
    rails_task_name = ""

    container_port     = var.container_port
    protected_username = var.protected_username
    protected_password = var.protected_password
    region             = var.aws.credentials.region
    rds_db_host        = module.rds.postgresql_address
    rds_db_name        = var.rds.postgresql.db_name
    rds_db_user        = var.rds.postgresql.db_username
    rds_db_password    = var.rds.postgresql.db_password
    redis_url          = local.redis_url
    sidekiq_username   = var.app_environments.sidekiq_username
    sidekiq_password   = var.app_environments.sidekiq_password
  })

  web_container_template_vars = merge(local.container_template_vars, {
    app_mode         = "web"
    container_cpu    = var.web_cpu
    container_memory = var.web_memory
  })

  queue_container_template_vars = merge(local.container_template_vars, {
    app_mode         = "queue"
    container_cpu    = var.queue_cpu
    container_memory = var.queue_memory
  })

  scheduled_task_container_template_vars = merge(local.container_template_vars, {
    app_mode         = "task"
    custom_command   = local.custom_task_command
    container_cpu    = var.task_cpu
    container_memory = var.task_memory
  })


}
