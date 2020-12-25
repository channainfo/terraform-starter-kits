variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  description = "[aws_security_group.database.id]"
  type        = list(string)
}

variable "identifier" {
  type = string
}

variable "postgresql_db_name" {
  type = string
}

variable "postgresql_db_username" {
  type = string
}

variable "postgresql_db_password" {
  type = string
}

variable "postgresql_engine_version" {
  description = "Engine version, default to the latest version"
  default     = ""
}

variable "postgresql_engine_class" {
  default = "db.t3.medium"
}
