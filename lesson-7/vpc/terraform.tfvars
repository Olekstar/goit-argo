aws_region   = "us-east-1"
aws_profile  = "goit-terraform"
name_prefix  = "goit-dev"
vpc_cidr     = "10.0.0.0/16"
azs          = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24",
  "10.0.13.0/24"
]
