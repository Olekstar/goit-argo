module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.name_prefix}-vpc"
  cidr = var.vpc_cidr

  azs             = var.azs
  public_subnets  = var.public_cidrs
  private_subnets = var.private_cidrs

  public_subnet_map_public_ip_on_launch  = true
  private_subnet_map_public_ip_on_launch = false

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Project"     = var.name_prefix
    "Environment" = "${var.name_prefix}"
  }
}
