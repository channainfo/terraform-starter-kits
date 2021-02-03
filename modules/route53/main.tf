data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "non_www" {
  zone_id = data.aws_route53_zone.main.zone_id

  name = ""
  type = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www"
  type    = "A"

  alias {
    name                   = var.lb_dns_name
    zone_id                = var.lb_zone_id
    evaluate_target_health = false
  }
}
resource "aws_route53_record" "sendgrid" {
  count   = length(var.sendgrid_settings)
  zone_id = data.aws_route53_zone.main.zone_id

  name    = var.sendgrid_settings[count.index].name
  type    = "CNAME"
  ttl     = "5"
  records = [var.sendgrid_settings[count.index].value]
}
