resource "aws_ecs_cluster" "main" {
  name = var.name
}

resource "aws_ecs_task_definition" "main" {
  family                   = var.name
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  container_definitions    = var.container_definitions
  task_role_arn            = var.task_role_arn
  execution_role_arn       = var.execution_role_arn
}

resource "aws_ecs_service" "main" {
  name            = var.name
  cluster         = aws_ecs_cluster.main.id
  launch_type     = "EC2"
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = var.desired_count

  tags = {
    "Name" = var.name
  }
}

# define a template for asg to use to launch ec2 an instance.
resource "aws_launch_configuration" "main" {
  name_prefix                 = "${var.name}-ecs-ec2"
  image_id                    = var.image_id
  instance_type               = var.instance_type
  enable_monitoring           = true
  associate_public_ip_address = true
  security_groups             = var.security_group_ids
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }

  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${var.name} >> /etc/ecs/ecs.config
EOF

}


resource "aws_autoscaling_group" "main" {
  name_prefix = var.name

  max_size                  = var.max_count
  min_size                  = var.min_count
  desired_capacity          = var.desired_count
  default_cooldown          = 300
  health_check_grace_period = 300
  health_check_type         = "EC2"

  force_delete         = true
  launch_configuration = aws_launch_configuration.main.name
  vpc_zone_identifier  = var.subnet_ids
  termination_policies = ["OldestInstance"]

  lifecycle {
    create_before_destroy = true
  }
}

# Policy to scale up and down.
# We use the cloudwatch to trigger the scale down and up
resource "aws_autoscaling_policy" "main_scale_up" {
  name                   = "${var.name}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

resource "aws_autoscaling_policy" "main_scale_down" {
  name                   = "${var.name}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

# Cloudwatch log event
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count               = var.metric_type == "Memory" ? 1 : 0
  alarm_name          = "${var.name}-Hight Memory"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "Ec2 memory for ASG ${var.name}"
  alarm_actions = [
    aws_autoscaling_policy.main_scale_up.arn
  ]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_low" {
  count               = var.metric_type == "Memory" ? 1 : 0
  alarm_name          = "${var.name}-Low Memory"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "System/Linux"
  period              = "300"
  statistic           = "Average"
  threshold           = "40"
  alarm_description   = "Ec2 memory for ASG ${var.name}"
  alarm_actions = [
    aws_autoscaling_policy.main_scale_down.arn
  ]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
}


resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = var.metric_type == "CPU" ? 1 : 0
  alarm_name          = "${var.name}-High CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "EC2 CPU for ASG ${var.name}"

  alarm_actions = [
    aws_autoscaling_policy.main_scale_up.arn
  ]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
}
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  count               = var.metric_type == "CPU" ? 1 : 0
  alarm_name          = "${var.name}-Low Memory"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "10"
  alarm_description   = "Ec2 CPU for ASG ${var.name}"
  alarm_actions = [
    aws_autoscaling_policy.main_scale_down.arn
  ]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }
}
