locals {
  test_json = {
    a = 10
    b = 10
  }
}

output "test_json_encode" {
  value = jsonencode(local.test_json)
}
