output "vpc" {
  value = {
    id = module.vpc.vpc_id
    az_names = module.vpc.az_names
    private_subnet_ids = module.vpc.private_subnet_ids
    public_subnet_ids = module.vpc.public_subnet_ids
  }
}

