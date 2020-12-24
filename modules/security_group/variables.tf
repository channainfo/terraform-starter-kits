variable "vpc_id" {
  description = "The id of your vpc"
  type        = string
}

variable "vpc_cidr" {
  type = string
}

variable "my_public_ip" {
  description = "Allow only this ip to connect. Leave it blank if anyone can access"
  default     = ""
}

variable "default_tags" {
  description = "Default tags"

  default = {

  }
}
