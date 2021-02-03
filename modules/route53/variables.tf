variable "domain_name" {
  description = "Domain name used in route 53 zone e.g. vtenh.com"
  type        = string
}

variable "lb_dns_name" {
  type = string
}

variable "lb_zone_id" {
  type = string
}

variable "sendgrid_settings" {
  default = []
}
