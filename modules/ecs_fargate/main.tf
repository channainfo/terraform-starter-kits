resource "aws_lb" "main" {
  name                       = var.name
  load_balancer_type         = "application"
  security_groups            = var.security_group_ids
  enable_deletion_protection = true
  subnets                    = var.subnet_ids
  internal                   = false
  tags                       = var.default_tags
}

resource "aws_alb_target_group" "main" {
  name        = var.name
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 30
    interval            = 180
    matcher             = "200"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.id
  port              = var.container_port
  protocol          = "HTTP"
  depends_on        = [aws_alb_target_group.main]

  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https" {
  load_balancer_arn = aws_lb.main.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn
  depends_on        = [aws_alb_target_group.main]

  default_action {
    target_group_arn = aws_alb_target_group.main.arn
    type             = "forward"
  }
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
  name            = var.name
  cluster         = aws_ecs_cluster.main.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count

  network_configuration {
    security_groups  = var.security_group_ids
    subnets          = var.subnet_ids
    assign_public_ip = true # for public subnet public ip must be true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.main.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }
}

resource "aws_appautoscaling_target" "main" {
  service_namespace = "ecs"

  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.main.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_count
  max_capacity       = var.max_count
}


resource "aws_appautoscaling_policy" "main_scale_up" {
  name               = "${var.name}-scale-up"
  service_namespace  = aws_appautoscaling_target.main.service_namespace
  resource_id        = aws_appautoscaling_target.main.resource_id
  scalable_dimension = aws_appautoscaling_target.main.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_appautoscaling_policy" "main_scale_down" {
  name               = "${var.name}-scale-down"
  service_namespace  = aws_appautoscaling_target.main.service_namespace
  resource_id        = aws_appautoscaling_target.main.resource_id
  scalable_dimension = aws_appautoscaling_target.main.scalable_dimension

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}


############################# Trigger auto scalling from CW metric ################################
#============================ Memory Variant ======================================================
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count               = var.metric_type == "Memory" ? 1 : 0
  alarm_name          = "${var.name}-High CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"

  alarm_actions = [
    aws_appautoscaling_policy.main_scale_up.arn
  ]

  dimensions = {
    ClusterName = var.name
    ServiceName = aws_ecs_service.main.name
  }

}

resource "aws_cloudwatch_metric_alarm" "memory_low" {
  count               = var.metric_type == "Memory" ? 1 : 0
  alarm_name          = "${var.name}-Low CPU"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "40"

  alarm_actions = [
    aws_appautoscaling_policy.main_scale_down.arn
  ]

  dimensions = {
    ClusterName = var.name
    ServiceName = aws_ecs_service.main.name
  }

}
#============================ CPU Variant ======================================================

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = var.metric_type == "CPU" ? 1 : 0
  alarm_name          = "${var.name}-High CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = 80

  alarm_actions = [
    aws_appautoscaling_policy.main_scale_up.arn
  ]

  dimensions = {
    ClusterName = var.name
    ServiceName = aws_ecs_service.main.name
  }

}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  count               = var.metric_type == "CPU" ? 1 : 0
  alarm_name          = "${var.name}-Low CPU"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "10"

  alarm_actions = [
    aws_appautoscaling_policy.main_scale_down.arn
  ]

  dimensions = {
    ClusterName = var.name
    ServiceName = aws_ecs_service.main.name
  }

}
