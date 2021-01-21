

variable "identifier" {
  description = "The name used as elasticache cluster id"
  type        = string
}

variable "node_type" {
  default = "cache.t3.small"
}

variable "parameter_group_name" {
  default = "default.redis6.x"
}

variable "engine_version" {
  default = "6.0.5"
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}
