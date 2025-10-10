# Backend конфігурація для ArgoCD
# Використовуємо той же S3 bucket що й для основної інфраструктури
terraform {
  backend "s3" {
    bucket  = "mlops-tfstate-goit-hw5-6"
    key     = "argocd/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    profile = "goit-terraform"
  }
}
