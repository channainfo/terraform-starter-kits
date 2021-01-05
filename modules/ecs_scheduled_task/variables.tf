variable "name" {
  type = string
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
  description = "cron(min hour day-of-month month day-of-week year)"
  type        = string
}


variable "schedule_expression_stop" {
  description = "cron(min hour day-of-month month day-of-week year). optional if is_scheduled_task"
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
