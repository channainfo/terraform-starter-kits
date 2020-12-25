output "task_role_arn" {
  value = aws_iam_role.ecs_task_assume_role.arn
}

output "execution_role_arn" {
  value = aws_iam_role.ecs_task_exec_role.arn
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.main.name
}
