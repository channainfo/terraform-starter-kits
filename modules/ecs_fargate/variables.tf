variable "default_tags" {
  default = {}
}
variable "name" {
  description = "Ecs fargate name"
  type        = string
}

variable "container_name" {
  type = string
}

variable "security_group_ids" {
  description = "List of security group id. e.g  aws_security_group.main.id "
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet id"
  type        = list
}

variable "vpc_id" {
  description = "The id of your vpc. e.g. aws_vpc.main.id"
  type        = string
}

variable "health_check_path" {
  description = "Health check path of your http. e.g /health_check"

  default = "/health_check"
}

variable "cpu" {
  description = "The number of CPU value. 1024 is equal 1CPU unit"
  type        = string
}

variable "memory" {
  description = "Then number of memory in MB"
  type        = string
}

variable "desired_count" {
  description = "The number of desired containers"
  default     = 1
}

variable "max_count" {
  description = "The number of max_capacity for autoscalling group"
  default     = 4
}

variable "min_count" {
  description = "The number of min_capacity for autoscalling group"
  default     = 1
}

variable "container_definitions" {
  description = "Container definition. data.template_file.container_def.rendered"
  type        = string
}

variable "container_port" {
  default = 80
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "acm_certificate_arn" {
  description = "The ARN of your SSL cert from ACM"
  type        = string
}

variable "metric_type" {
  description = "CW Metric type (CPU or Memory) to use to trigger auto scalling. Default to CPU"
  default     = "CPU"
}

variable "domain_name" {
  description = "The domain name. e.g vtenh.com"
  type        = string
}

variable "container_insights" {
  type    = bool
  default = true
}
