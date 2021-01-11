

output "test1" {
  value = data.template_file.test1.rendered
}

output "test2" {
  value = data.template_file.test2.rendered
}

output "custom_command" {
  value = local.custom_task_command
}
