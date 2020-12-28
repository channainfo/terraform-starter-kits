variable "name" {
  description = "The name of ecs ec2 instances"
  type        = string
}

variable "task_cpu" {
  description = "The task_cpu of the task in MB. This should be greater than container_memory"
}

variable "task_memory" {
  description = "The memory of the task in MB. This should be greater than container_memory"
}

variable "image_id" {
  description = "Amazon machine image id (ami)"
  type        = string
}

variable "instance_type" {
  description = "Amazaon ec2 instance type: e.g. t3a.medium"
  type        = string
}

variable "vpc_id" {
  description = "The id of the VPC"
  type        = string
}

variable "security_group_ids" {
  description = "A List of Security group ids"
  type        = list(string)
}

variable "subnet_ids" {
  description = "A list of subnet ids (public) for vpc zone identifier"
  type        = list(string)
}

variable "key_name" {
  description = "The key name to link to ec2"
  type        = string
}

variable "max_count" {
  default = 4
}

variable "min_count" {
  default = 1
}

variable "desired_count" {
  default = 1
}

variable "container_cpu" {
  description = "The number of CPU for docker container, 1Cpu unit = 1028"
  type        = string
  default     = "1024"
}

variable "container_memory" {
  description = "The amount of memory given to docker container in MB"
  type        = string
  default     = "1024"
}

variable "container_definitions" {
  description = "Container definition. data.template_file.container_def.rendered"
  type        = string
}

variable "container_port" {
  default = 80
}

variable "iam_instance_profile" {
  description = "The name of for ec2 instance profile"
  type        = string
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "metric_type" {
  description = "The metric type to use. Possible value is (CPU, Memory). Default is CPU"
  default     = "CPU"
}
