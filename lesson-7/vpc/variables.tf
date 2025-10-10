variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "aws_profile" {
  description = "AWS profile name for credentials"
  type        = string
  default     = "default"
}

variable "name_prefix" {
  description = "Name prefix for all resources"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
}

variable "public_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "private_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
}
