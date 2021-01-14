variable "vars" {
  default = {
    custom_command = ""
    container_name = "ami-hello"
  }
}


data "template_file" "test1" {
  template = file("template/test.json.tpl")
  vars     = var.vars
}

data "template_file" "test2" {
  template = file("template/test.json.tpl")
  vars = merge(var.vars, {
    custom_command = "\"hello\": \"world\","
  })
}
