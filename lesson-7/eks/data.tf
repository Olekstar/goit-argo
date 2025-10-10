data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket  = "mlops-tfstate-goit-hw5-6"
    key     = "vpc/terraform.tfstate"
    region  = "us-east-1"
    profile = "goit-terraform"
  }
}
