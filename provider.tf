provider "aws" {
  access_key = var.aws.credentials.access_key
  secret_key = var.aws.credentials.secret_key
  region     = var.aws.credentials.region
}
