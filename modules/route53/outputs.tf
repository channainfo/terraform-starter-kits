output "www_name" {
  value = aws_route53_record.www.name
}

output "www_fqdn" {
  value = aws_route53_record.www.fqdn
}

output "non_www_name" {
  value = aws_route53_record.non_www.name
}

output "non_www_fqdn" {
  value = aws_route53_record.non_www.fqdn
}
