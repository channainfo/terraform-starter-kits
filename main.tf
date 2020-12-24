module "vpc" {
  source = "./modules/vpc"

  name   = var.name
  region = var.aws.credentials.region

  default_tags = local.default_tags
}

module "sg" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr

  default_tags = local.default_tags
}
