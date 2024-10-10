# AWS Networking Infrastructure

This project sets up a basic AWS networking infrastructure using Terraform.

## Overview

This Terraform configuration creates a Virtual Private Cloud (VPC) with public and private subnets across three availability zones, along with the necessary routing tables and an Internet Gateway.

## Resources Created

- 1 VPC
- 3 Public Subnets
- 3 Private Subnets
- 1 Internet Gateway
- 1 Public Route Table
- 1 Private Route Table
- Appropriate route table associations


## Variables

The following variables are used in this configuration:

- `aws_region`: The AWS region to deploy the resources
- `aws_profile`: The AWS CLI profile to use
- `vpc_cidr`: The CIDR block for the VPC
- `public_subnet_cidr_1`, `public_subnet_cidr_2`, `public_subnet_cidr_3`: CIDR blocks for public subnets
- `private_subnet_cidr_1`, `private_subnet_cidr_2`, `private_subnet_cidr_3`: CIDR blocks for private subnets
- `az_1`, `az_2`, `az_3`: Availability zones to use

Ensure these variables are defined in a `variables.tf` file or passed when running Terraform.

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed

## Usage

1. Clone this repository
2. Navigate to the project directory
3. Initialize Terraform: `terraform init`
4. Review the planned changed: `terraform plan`
5. Apply the changes: `terraform apply`
   
## Cleanup

To remove all created resources: `terraform destroy`