resource "aws_iam_role" "main" {
  name               = var.name
  assume_role_policy = file("${path.module}/template/role.json")
}

resource "aws_iam_role_policy" "main" {
  name   = var.name
  role   = aws_iam_role.main.id
  policy = file("${path.module}/template/policy.json")
}

resource "aws_ecs_cluster" "main" {
  name = var.name
}

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

resource "aws_ecs_service" "main" {
  count = var.is_scheduled_task == true ? 1 : 0

  name            = var.name
  cluster         = aws_ecs_cluster.main.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1

  network_configuration {
    security_groups  = var.security_group_ids
    subnets          = var.subnet_ids
    assign_public_ip = true # for public subnet public ip must be true
  }
}

resource "aws_appautoscaling_target" "main" {
  count             = var.is_scheduled_task == true ? 1 : 0
  service_namespace = "ecs"

  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main[0].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  max_capacity       = 1
  min_capacity       = 0
}

resource "aws_appautoscaling_scheduled_action" "start_task" {
  count              = var.is_scheduled_task == true ? 1 : 0
  name               = "${var.name}-task-start"
  service_namespace  = aws_appautoscaling_target.main[0].service_namespace
  resource_id        = aws_appautoscaling_target.main[0].resource_id
  scalable_dimension = aws_appautoscaling_target.main[0].scalable_dimension

  # At expressions - at(yyyy-mm-ddThh:mm:ss), Rate expressions - rate(valueunit), Cron expressions - cron(fields).
  # In UTC. https://docs.aws.amazon.com/autoscaling/application/APIReference/Welcome.html
  schedule = var.schedule_expression_start
  scalable_target_action {
    min_capacity = 1
    max_capacity = 1
  }
}

resource "aws_appautoscaling_scheduled_action" "stop_task" {
  count              = var.is_scheduled_task == true ? 1 : 0
  name               = "${var.name}-task-stop"
  service_namespace  = aws_appautoscaling_target.main[0].service_namespace
  resource_id        = aws_appautoscaling_target.main[0].resource_id
  scalable_dimension = aws_appautoscaling_target.main[0].scalable_dimension

  # At expressions - at(yyyy-mm-ddThh:mm:ss), Rate expressions - rate(valueunit), Cron expressions - cron(fields).
  # In UTC. https://docs.aws.amazon.com/autoscaling/application/APIReference/Welcome.html
  schedule = var.schedule_expression_stop

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }
}

#####
# Cloudwatch event rule and target is the defacto scheduled task by AWS.
# However I could not find a way to stop the task.
#####
resource "aws_cloudwatch_event_rule" "main" {
  count = var.is_scheduled_task == false ? 1 : 0

  name = var.name
  # CloudWatch Events supports Cron Expressions and Rate Expressions
  # For example, "cron(0 20 * * ? *)" or "rate(5 minutes)".
  # https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
  schedule_expression = var.schedule_expression_start
}

resource "aws_cloudwatch_event_target" "main" {
  count = var.is_scheduled_task == false ? 1 : 0

  rule = aws_cloudwatch_event_rule.main[0].id
  arn  = aws_ecs_cluster.main.arn

  target_id = "${var.name}_scheduleed_task"
  role_arn  = aws_iam_role.main.arn

  ecs_target {
    task_definition_arn = aws_ecs_task_definition.main.arn
    task_count          = 1
    launch_type         = "FARGATE"

    network_configuration {
      security_groups  = var.security_group_ids
      subnets          = var.subnet_ids
      assign_public_ip = true
    }
  }
}
