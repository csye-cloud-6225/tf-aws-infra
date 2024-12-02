# AWS Cloud Infrastructure with Terraform

This project uses **Terraform** to set up a complete AWS cloud infrastructure, including networking, compute, storage, security, monitoring, and serverless functionality.

---

## Overview

This Terraform configuration automates the creation of a scalable and secure AWS infrastructure. The setup includes a VPC with public and private subnets, an Internet Gateway, application and database security groups, RDS, S3 with server-side encryption, and serverless Lambda integration with SNS notifications.

---

## Key Features

### Networking
- **VPC**: A virtual private cloud for isolating your infrastructure.
- **Subnets**: 
  - 3 public subnets
  - 3 private subnets
- **Route Tables**: Separate public and private route tables with proper associations.
- **Internet Gateway**: To enable outbound connectivity for public subnets.

### Compute
- **Auto Scaling Group (ASG)**: Manages EC2 instances with auto-scaling policies based on CPU utilization.
- **Launch Template**: Configures instances with a secure IAM role, encrypted EBS volumes, and custom user data scripts.

### Database
- **RDS (MySQL)**: Secure database setup with encrypted storage and a custom parameter group.
- **Database Security Group**: Restricts access to the database to application-level security groups.

### Storage
- **S3 Bucket**: 
  - Configured with server-side encryption using KMS keys.
  - Lifecycle management to transition data to **STANDARD_IA** after 30 days.
  - Public access blocked for security.

### Monitoring and Notifications
- **CloudWatch**: Collects metrics and logs for monitoring EC2 and ASG health.
- **SNS Topic**: Sends notifications for specific events (e.g., user creation).
- **CloudWatch Alarms**: Triggers scaling policies based on CPU utilization.

### Serverless
- **AWS Lambda**: Implements a user verification function triggered by SNS.
- **IAM Roles and Policies**: 
  - Allows Lambda to interact with SNS, RDS, and Secrets Manager.
  - Manages S3 and CloudWatch permissions.

### Security
- **IAM Roles**: Configured for EC2 and Lambda with scoped permissions.
- **KMS Keys**: Provides encryption for EBS volumes, RDS, S3, and Secrets Manager.

---

## Resources Created

### Networking
- 1 VPC
- 3 Public Subnets
- 3 Private Subnets
- 1 Internet Gateway
- 1 Public Route Table
- 1 Private Route Table
- 6 Route Table Associations

### Compute
- Auto Scaling Group with 3 EC2 instances (minimum size: 3, maximum size: 5)
- Launch Template

### Storage
- S3 bucket with lifecycle management and server-side encryption
- Encrypted EBS volumes attached to EC2 instances

### Database
- MySQL RDS instance
- Parameter group and subnet group for RDS

### Security
- IAM roles for EC2, Lambda, and Auto Scaling
- Security groups for:
  - Load balancer
  - Application instances
  - RDS database
- KMS keys for:
  - S3
  - RDS
  - EBS
  - Secrets Manager

### Monitoring & Serverless
- Lambda function with SNS triggers
- CloudWatch logs and alarms

---

## Commands to Import SSL Certificate

To use an SSL certificate with the Application Load Balancer (ALB), the certificate must be imported into AWS Certificate Manager (ACM). Use the following command:

```bash
aws acm import-certificate \
    --certificate file://path/to/certificate.pem \
    --private-key file://path/to/private-key.pem \
    --certificate-chain file://path/to/certificate-chain.pem \
    --region your-aws-region
```

Replace:
- `path/to/certificate.pem` with the path to your SSL certificate file.
- `path/to/private-key.pem` with the path to your private key file.
- `path/to/certificate-chain.pem` with the path to your certificate chain file.
- `your-aws-region` with the AWS region where you want to import the certificate.

Once imported, use the ARN of the certificate in the `demo_certificate_arn` field of the Terraform configuration.

---

## Prerequisites

1. **AWS CLI**: Installed and configured with appropriate credentials and profiles.
2. **Terraform**: Installed and initialized in the project directory.
3. **SSL Certificate**: Available in PEM format for HTTPS setup on the Application Load Balancer.

---

## Usage

### 1. Clone the Repository
```bash
git clone <repository-url>
cd <repository-directory>
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Review Changes
```bash
terraform plan
```

### 4. Apply Changes
```bash
terraform apply
```

### 5. Test the Setup
- **Access Load Balancer**: Use the ALB DNS name to access the application.
- **S3 Operations**: Verify S3 bucket lifecycle and encryption.
- **RDS Connection**: Confirm the database is accessible via the application.
- **Lambda**: Test the SNS-triggered Lambda function.

---

## Outputs

The following outputs are displayed after applying Terraform:
- **RDS Endpoint**: Connection string for the MySQL database.
- **S3 Bucket Name**: Name of the private S3 bucket.
- **ALB DNS Name**: DNS for accessing the application.
- **SNS Topic ARN**: ARN of the SNS topic for notifications.
- **Lambda Function Name**: Name of the deployed Lambda function.

---

## Cleanup

To delete all resources, run:
```bash
terraform destroy
```
