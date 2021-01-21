variable "name" {
  type = string
}
variable "ecs_cluster_name" {
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
