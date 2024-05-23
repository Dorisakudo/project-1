variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "eu-west-2"
}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
  default     = "t2.medium"
}

variable "key_name" {
  description = "The name of the key pair to use for the instance"
  type        = string
  default     = "production"
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
  default     = "jenkins34_sg"
}
