locals {
  name_prefix = "${var.project_name}-${var.environment}"
}

module "vpc" {
  source = "./vpc"

  aws_region   = var.aws_region
  name_prefix  = local.name_prefix
  vpc_cidr     = "10.0.0.0/16"
  azs          = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  public_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_cidrs = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24"
  ]
}

module "eks" {
  source = "./eks"

  aws_region  = var.aws_region
  name_prefix = local.name_prefix

  # expect module eks to read vpc outputs via remote state
}
