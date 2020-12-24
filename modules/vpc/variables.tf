variable "name" {
  description = "The name of vpc"
  type        = string
}

variable "vpc_cidr" {
  type    = string
  default = "192.168.0.0/16"
}

variable "subnet_cidr_format" {
  default = "192.168.x.0/24"
}

variable "region" {
  description = "The region name of your vpc"
  type        = string
}

variable "default_tags" {
  description = "The default tag"

  default = {
    AutoManaged = "This resource is auto generated. Not recommend to change"
  }
}
