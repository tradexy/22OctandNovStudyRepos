variable "aws_region" {
  description = "regions"
  default     = "us-east-1"
}

variable "name_tag" {
  description = "name of the vpc"
}

variable "vpc_cidr_block" {
  description = "cidr_block for VPC"
}

variable "environment_tag" {
  description = "Development"
}

variable "public_subnet_cidr_block" {
  description = "cidr_block for Public Subnet"
}

variable "ingressfromport" {
  description = "ingress from port"
}

variable "ingresstoport" {
  description = "ingress to port"
}

variable "IpAddress" {
  description = "ip address of your choice"
}

variable "egressfromport" {
  description = "egress from port"
}

variable "egresstoport" {
  description = "egress to port"
}

variable "protocol" {
  description = "protocol for security group"
}

variable "key_name" {
  description = "name of key pair"
}

variable "ec2_ami" {
  description = "ami of EC2"
}

variable "ec2_type" {
  description = "type of EC2"
}

variable "availability_zones" {
  description = "AZs of VPC"
}