
variable "ecs_cluster_name" {
  type = string
}

variable "task_arn" {
  type = string
}

variable "profile" {
  type = string
}

variable "region" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "subnet_ids" {
  type = list(string)
}
