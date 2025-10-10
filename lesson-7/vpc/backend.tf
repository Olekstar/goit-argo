terraform {
  backend "s3" {
    bucket  = "mlops-tfstate-goit-hw5-6"
    key     = "vpc/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    profile = "goit-terraform"
  }
}
