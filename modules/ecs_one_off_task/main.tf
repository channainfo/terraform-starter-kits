
resource "aws_ecs_task_definition" "main" {
  family                   = var.name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions    = var.container_definitions
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
}

locals {
  network_configuration = {
    awsvpcConfiguration = {
      securityGroups = var.security_group_ids
      subnets        = var.subnet_ids
    }
  }

  # aws ecs run-task --cluster VTENH-fargate --task-definition 'arn:aws:ecs:ap-southeast-1:611922433325:task-definition/VTENH-db-migration:9' \
  # --profile vtenh --region ap-southeast-1 --network-configuration \
  # '{"awsvpcConfiguration":{"securityGroups":["sg-0b8f764c7f3bf5570"],"subnets":["subnet-0537278cba0fe9a9b", "subnet-0b390072549da094e","subnet-07f858c291d262ae0"]}}'
  command = <<EOD
      aws ecs run-task --cluster ${var.ecs_cluster_name} --task-definition '${aws_ecs_task_definition.main.arn}' --launch-type FARGATE \
      --profile ${var.profile} --region ${var.region} --network-configuration '${jsonencode(local.network_configuration)}'
EOD
}

resource "null_resource" "ecs-run-task" {
  provisioner "local-exec" {
    # add other args as necessary: https://docs.aws.amazon.com/cli/latest/reference/ecs/run-task.html
    command = local.command
  }
}
