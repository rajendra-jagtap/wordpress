variable "ami_id" {
  type        = string
  description = "The AMI ID to be used for the EC2 instances."
}

variable "instance_types" {
  type        = map(string)
  description = "A map of instance types for each environment."
  default = {
    dev   = "t2.micro"
    stage = "t2.micro"
    prod  = "t2.micro"
  }
}

variable "key_name" {
  type        = string
  description = "The key name of the Amazon EC2 key pair."
}

variable "subnets" {
  type        = list(string)
  description = "A list of subnet IDs to launch resources in."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where resources will be created."
}

variable "region" {
  type        = string
  description = "The AWS region where resources will be deployed."
  default     = "ap-south-1"
}
