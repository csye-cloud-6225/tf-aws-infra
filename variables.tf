variable "aws_region" {
  description = "AWS Region"
  type        = string
}
variable "aws_profile" {
  description = "The AWS CLI profile to use for deploying resources"
  type        = string
}
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr_1" {
  description = "CIDR block for public subnet 1"
  type        = string
}

variable "public_subnet_cidr_2" {
  description = "CIDR block for public subnet 2"
  type        = string
}

variable "public_subnet_cidr_3" {
  description = "CIDR block for public subnet 3"
  type        = string
}

variable "private_subnet_cidr_1" {
  description = "CIDR block for private subnet 1"
  type        = string
}

variable "private_subnet_cidr_2" {
  description = "CIDR block for private subnet 2"
  type        = string
}

variable "private_subnet_cidr_3" {
  description = "CIDR block for private subnet 3"
  type        = string
}

variable "az_1" {
  description = "Availability Zone 1"
  type        = string
}

variable "az_2" {
  description = "Availability Zone 2"
  type        = string
}

variable "az_3" {
  description = "Availability Zone 3"
  type        = string
}
