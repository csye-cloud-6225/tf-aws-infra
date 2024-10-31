variable "aws_region" {
  description = "AWS Region"
  type        = string
}
variable "aws_profile" {
  description = "The AWS CLI profile to use for deploying resources"
  type        = string
}
variable "AWS_ACCESS_KEY" {
  description = "The AWS CLI profile to use for deploying resources"
  type        = string
}
variable "AWS_SECRET_ACCESS_KEY" {
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
variable "custom_ami" {
  description = "The AMI ID for the EC2 instance."
  type        = string
}
variable "db_username" {
  description = "The username of the database"
}

variable "db_password" {
  description = "The password for the database"
}
variable "db_name" {
  description = "Database name"
}


variable "db_port" {
  description = "Database port"
}

variable "bucket_name" {
  description = "The name of the S3 bucket for artifacts"
  type        = string
}

variable "zone_id" {
  description = "The ID of the Route 53 hosted zone"
  type        = string
}

variable "record_name" {
  default     = "dev"
  description = "The DNS record name for the EC2 instance"
  type        = string
}

variable "db_sg_description" {
  description = "Description for the database security group"
  type        = string
}
variable "assignment" {
  description = "Assignment name for the bucket"
  default     = "my-assignment"
}

variable "domain_name" {
  description = "Domain name for Route 53 DNS configuration"
  default     = "dev.cloudnativeapplication.works"
}

variable "record_type" {
  description = "Type of DNS record (e.g., A or CNAME)"
  default     = "A"
}

variable "ttl" {
  description = "Time-to-live value for DNS records"
  default     = 300
}
