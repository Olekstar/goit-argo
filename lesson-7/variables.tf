variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile name for credentials"
  type        = string
  default     = "default"
}

variable "project_name" {
  description = "Base project name"
  type        = string
  default     = "eks-vpc-cluster"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "dev"
}
