variable "region" {
  description = "The AWS region to deploy the EKS cluster in."
  default     = "eu-west-2"
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  default     = "finance-cluster"
}

variable "cluster_version" {
  description = "The Kubernetes version for the EKS cluster."
  default     = "1.27"
}

variable "desired_capacity" {
  description = "Desired number of worker nodes."
  default     = 2
}

variable "max_capacity" {
  description = "Maximum number of worker nodes."
  default     = 3
}

variable "min_capacity" {
  description = "Minimum number of worker nodes."
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type for the worker nodes."
  default     = "t3.medium"
}

variable "key_name" {
  description = "The name of the EC2 Key Pair to allow SSH access to the instances."
  default     = "production"
}
