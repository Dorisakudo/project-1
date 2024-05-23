variable "instance_name" {
  description = "The name of the instance"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
}

variable "key_name" {
  description = "The name of the key pair to use for the instance"
  type        = string
}

variable "security_group_id" {
  description = "The security group ID to attach to the instance"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID to use for the instance"
  type        = string
}

variable "user_data" {
  description = "The user data to configure the instance"
  type        = string
}
