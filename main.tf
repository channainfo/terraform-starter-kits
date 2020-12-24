module "vpc" {
  source = "./modules/vpc"

  name   = var.resource.name
  region = var.aws.credentials.region

  default_tags = var.default_tags
}
