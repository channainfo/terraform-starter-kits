

variable "identifier" {
  description = "The name used as elasticache cluster id"
  type        = string
}

variable "node_type" {
  default = "cache.t3.small"
}

variable "parameter_group_name" {
  default = "default.memcached1.6"
}

variable "engine_version" {
  default = "1.6.6"
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}
