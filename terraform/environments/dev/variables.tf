variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.33"
}

variable "node_instance_type" {
  description = "EKS worker node instance type"
  type        = string
  default     = "t3.medium"
}

variable "node_min_size" {
  description = "Minimum EKS node count"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum EKS node count"
  type        = number
  default     = 3
}

variable "node_desired_size" {
  description = "Desired EKS node count"
  type        = number
  default     = 2
}

variable "name" {
  description = "Name prefix for the infrastructure"
  type        = string
  default     = "devops-platform-dev"
}