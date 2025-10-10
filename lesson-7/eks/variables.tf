variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS profile name for credentials"
  type        = string
  default     = "goit-terraform"
}

variable "name_prefix" {
  description = "Name prefix for cluster"
  type        = string
  default     = "goit"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "goit"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31"
}
