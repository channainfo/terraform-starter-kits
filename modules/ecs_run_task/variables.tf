variable "name" {
  type = string
}

variable "ecs_cluster" {
  description = "if ecs_cluster is missing then this module will create a new cluster"
  default     = ""
}

variable "cpu" {
  type = string
}

variable "memory" {
  type = string
}

variable "container_definitions" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "execution_role_arn" {
  type = string
}

variable "schedule_expression_start" {
  description = "cron(min hour day-of-month month day-of-week year). Required if is_scheduled_task is false"
  type        = string
  default     = ""
}


variable "schedule_expression_stop" {
  description = "cron(min hour day-of-month month day-of-week year). optional if is_scheduled_task. Required if is_scheduled_task is true"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "assign_public_ip" {
  default = true
}

variable "is_scheduled_task" {
  default = true
}
