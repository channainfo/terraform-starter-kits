variable "bucket_name" {
  description = "The name of your bucket ( No dot .)"
  type        = string
}

variable "sites" {
  description = "The list of your sites .eg. [https://www.vtenh.com, https://vtenh.com]"
  type        = list(string)
}
