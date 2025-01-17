provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # Update this to the latest version you are using
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Main VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Main IGW"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.public_subnet_cidr_1
  availability_zone = var.az_1

  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet 1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_cidr_2
  availability_zone       = var.az_2
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet 2"
  }
}

resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_cidr_3
  availability_zone       = var.az_3
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet 3"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidr_1
  availability_zone = var.az_1

  tags = {
    Name = "Private Subnet 1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidr_2
  availability_zone = var.az_2

  tags = {
    Name = "Private Subnet 2"
  }
}

resource "aws_subnet" "private_subnet_3" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidr_3
  availability_zone = var.az_3

  tags = {
    Name = "Private Subnet 3"
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Public Route Table"
  }
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Private Route Table"
  }
}

# Public Route
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_association_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_association_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_association_3" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.public_rt.id
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private_association_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_association_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_association_3" {
  subnet_id      = aws_subnet.private_subnet_3.id
  route_table_id = aws_route_table.private_rt.id
}
# Security Groups
# Load Balancer Security Group
resource "aws_security_group" "load_balancer_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "Load Balancer Security Group" }
}
# Application Security Group
resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Application Security Group"
  }

  ingress {
    from_port   = 22 # SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80 # HTTP
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id]
  }

  ingress {
    from_port       = 443 # HTTPS
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id]
  }

  ingress {
    from_port       = 8080 # Custom Application Port
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.load_balancer_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Database Security Group
resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Database Security Group"
  }

  # Ingress rule to allow traffic from the application security group
  ingress {
    from_port       = 3306 # MySQL
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  # Restrict egress to allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# RDS Parameter Group
resource "aws_db_parameter_group" "my_db_parameter_group" {
  name        = "csye6225-parameter-group"
  family      = "mysql8.0"
  description = "Parameter group for MySQL 8.0"

  tags = {
    Name = "MySQL Parameter Group"
  }
}

# RDS Subnet Group (for private subnets)
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name = "my-db-subnet-group"
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id,
    aws_subnet.private_subnet_3.id,
  ]

  tags = {
    Name = "My DB Subnet Group"
  }
}

# RDS Instance (MySQL Example)
resource "aws_db_instance" "my_database" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.my_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_name                = var.db_name
  username               = var.db_username
  password               = random_password.db_password.result
  parameter_group_name   = aws_db_parameter_group.my_db_parameter_group.name
  kms_key_id             = aws_kms_key.rds_kms_key.arn
  storage_encrypted      = true

  skip_final_snapshot = true

  tags = {
    Name = "My Database Instance"
  }
}

# Output the database endpoint
output "db_instance_endpoint" {
  value = aws_db_instance.my_database.address
}


# Generate Random ID for Bucket Name
resource "random_id" "bucket_name" {
  byte_length = 7
}

# S3 Bucket Configuration
resource "aws_s3_bucket" "private_webapp_bucket" {
  bucket = "s3-${var.assignment}-${random_id.bucket_name.hex}"

  force_destroy = true # Allow deletion of non-empty bucket

  tags = {
    Name        = "Terraform Private S3 Bucket"
    Environment = "${var.assignment} - S3 Bucket"
  }
}

# S3 Bucket Lifecycle Configuration (Transition to STANDARD_IA after 30 days)
resource "aws_s3_bucket_lifecycle_configuration" "s3_lifecycle_config" {
  bucket = aws_s3_bucket.private_webapp_bucket.bucket

  rule {
    id = "lifecycle"
    filter {}

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    status = "Enabled"
  }
}

# Enable Default Encryption on S3 Bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_key_encryption" {
  bucket = aws_s3_bucket.private_webapp_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      # sse_algorithm = "AES256"
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_kms_key.arn
    }
  }
}

# Restrict Public Access to S3 Bucket
resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block" {
  bucket = aws_s3_bucket.private_webapp_bucket.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM Role for EC2 to Access S3 Bucket
resource "aws_iam_role" "s3_access_role_to_ec2" {
  name = "CSYE6225-S3BucketAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Sid       = "RoleForEC2",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# IAM Policy for S3 Bucket Access
resource "aws_iam_policy" "s3_access_policy" {
  name        = "WebappS3AccessPolicy"
  description = "Policy for accessing the private S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:ListBucket", "s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.private_webapp_bucket.bucket}/*",
          "arn:aws:s3:::${aws_s3_bucket.private_webapp_bucket.bucket}"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics",
          "cloudwatch:CreateLogGroup",
          "cloudwatch:CreateLogStream",
          "cloudwatch:PutLogEvents"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Resource = "${aws_kms_key.s3_kms_key.arn}"
      }
    ]
  })
}

# Fetch CloudWatch Policy
data "aws_iam_policy" "cloudwatch_policy" {
  name = "CloudWatchAgentServerPolicy"
}

# Attach Policies to EC2 Role
resource "aws_iam_policy_attachment" "policy_role_attach_s3" {
  name       = "policy_role_attach_s3"
  roles      = [aws_iam_role.s3_access_role_to_ec2.name]
  policy_arn = aws_iam_policy.s3_access_policy.arn
}

resource "aws_iam_policy_attachment" "policy_role_attach_cloudwatch" {
  name       = "policy_role_attach_cloudwatch"
  roles      = [aws_iam_role.s3_access_role_to_ec2.name]
  policy_arn = data.aws_iam_policy.cloudwatch_policy.arn
}

# Create Instance Profile for EC2 Role
resource "aws_iam_instance_profile" "ec2_role_profile" {
  name = "ec2_role_profile"
  role = aws_iam_role.s3_access_role_to_ec2.name
}

# Launch Template for Auto-Scaling Group
resource "aws_launch_template" "web_app_launch_template" {
  name          = "csye6225_asg"
  image_id      = var.custom_ami
  instance_type = "t2.micro"
  key_name      = var.aws_keyname

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_role_profile.name
  }
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      volume_size           = 50
      volume_type           = "gp2"
      encrypted             = true
      kms_key_id            = aws_kms_key.ec2_kms_key.arn
    }
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_sg.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "DB_PASSWORD=${random_password.db_password.result}" >> /etc/environment
    export DB_PASSWORD=${random_password.db_password.result}
    echo "DB_HOST=${aws_db_instance.my_database.address}" >> /etc/environment
    echo "DB_USER=${var.db_username}" >> /etc/environment
    echo "DB_NAME=${var.db_name}" >> /etc/environment
    echo "DB_PORT=${var.db_port}" >> /etc/environment
    # echo "DB_PASSWORD=${var.db_password}" >> /etc/environment
    echo "aws_region=${var.aws_region}" >> /etc/environment
    echo "bucket_name=${aws_s3_bucket.private_webapp_bucket.bucket}" >> /etc/environment
    echo "SNS_TOPIC_ARN=${aws_sns_topic.new_user_topic.arn}" >> /etc/environment
    source /etc/environment
    sudo systemctl restart my-app.service
    cd /opt/webapp
    sudo -u csye6225 npx sequelize-cli db:migrate
    sudo systemctl restart my-app.service
    sudo systemctl restart amazon-cloudwatch-agent
  EOF
  )
  tags = {
    Name = "WebApp Instance"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web_app_asg" {
  name                = "csye6225_asg"
  desired_capacity    = 3
  min_size            = 3
  max_size            = 5
  vpc_zone_identifier = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id, aws_subnet.public_subnet_3.id]
  launch_template {
    id      = aws_launch_template.web_app_launch_template.id
    version = "$Latest"
  }

  target_group_arns         = [aws_lb_target_group.web_app_target_group.arn]
  health_check_type         = "EC2"
  health_check_grace_period = 300
  tag {
    key                 = "AutoScalingGroup"
    value               = "WebApp"
    propagate_at_launch = true
  }
}

# resource "aws_autoscaling_policy" "scale_policy" {
#   name                   = "scale-policy"
#   policy_type            = "TargetTrackingScaling"
#   autoscaling_group_name = aws_autoscaling_group.web_app_asg.name

#   target_tracking_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ASGAverageCPUUtilization"
#     }
#     target_value = 50 # Adjust this as needed for your application
#   }
# }
# Step 13: Scale Up Policy
resource "aws_autoscaling_policy" "scale_up" {
  name                    = "scale-up-policy"
  scaling_adjustment      = 1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 60
  autoscaling_group_name  = aws_autoscaling_group.web_app_asg.name
  metric_aggregation_type = "Average"
}

# Step 13.1: CloudWatch Alarm for Scaling Up
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "high-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 12
  alarm_actions       = [aws_autoscaling_policy.scale_up.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_app_asg.name
  }
}

# Step 14: Scale Down Policy
resource "aws_autoscaling_policy" "scale_down" {
  name                    = "scale-down-policy"
  scaling_adjustment      = -1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 60
  autoscaling_group_name  = aws_autoscaling_group.web_app_asg.name
  metric_aggregation_type = "Average"
}

# Step 14.1: CloudWatch Alarm for Scaling Down
resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  alarm_name          = "low-cpu-alarm"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 8
  alarm_actions       = [aws_autoscaling_policy.scale_down.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_app_asg.name
  }
}

# Application Load Balancer
resource "aws_lb" "web_app_alb" {
  name               = "csye6225-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id, aws_subnet.public_subnet_3.id]

  tags = {
    Name = "WebApp-ALB"
  }
}
# IAM Role for Auto-Scaling Group
resource "aws_iam_role" "autoscaling_role" {
  name = "autoscaling-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "autoscaling.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}
# Target Group for Auto Scaling Group
resource "aws_lb_target_group" "web_app_target_group" {
  name     = "csye6225-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    enabled             = true
    path                = "/healthz"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 10
    unhealthy_threshold = 10
  }



  tags = { Name = "WebApp-TargetGroup" }
}

# Listener for Load Balancer
resource "aws_lb_listener" "web_app_https_listener" {
  load_balancer_arn = aws_lb.web_app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08" # Use a valid security policy
  certificate_arn   = var.demo_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_app_target_group.arn
  }
}




# Route 53 Zone Data Source
data "aws_route53_zone" "selected_zone" {
  name         = var.domain_name
  private_zone = false
}
# Route 53 A Record Mapping to Load Balancer
resource "aws_route53_record" "server_mapping_record" {
  zone_id = data.aws_route53_zone.selected_zone.zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_lb.web_app_alb.dns_name
    zone_id                = aws_lb.web_app_alb.zone_id
    evaluate_target_health = true
  }
}

# Output the Load Balancer DNS
output "load_balancer_dns" {
  value = aws_lb.web_app_alb.dns_name
}

resource "aws_sns_topic" "new_user_topic" {
  name         = "new-user-topic"
  display_name = "New User Account Creation"
}

output "sns_topic_arn" {
  value = aws_sns_topic.new_user_topic.arn
}
resource "aws_iam_role" "lambda_role" {
  name = "lambda_sns_rds_email_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_sns_rds_email_policy" {
  name        = "lambda_sns_rds_email_policy"
  description = "Policy for Lambda to access SNS, RDS, and email services"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sns:Publish",
          "sns:Subscribe",
          "rds:DescribeDBInstances",
          "rds:ExecuteStatement"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ses:SendEmail"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_role_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_sns_rds_email_policy.arn
  role       = aws_iam_role.lambda_role.name
}

resource "aws_lambda_function" "user_verification_lambda" {
  function_name = "user-verification-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "serverless/index.handler"                                                             # Your Lambda function entry point
  runtime       = "nodejs18.x"                                                                           # Or another runtime of your choice
  filename      = "C:/Users/hp/Downloads/Nilvi_Shah_002838651_08/Nilvi_Shah_002838651_08/serverless.zip" # Path to your zip file containing the Lambda code

  environment {
    variables = {
      # SENDGRID_API_KEY = var.sendgrid_api_key
      # SNS_TOPIC_ARN    = aws_sns_topic.new_user_topic.arn
      baseURL = var.baseURL
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_role_policy_attachment]
}
resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_verification_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.new_user_topic.arn
}

resource "aws_iam_policy" "sns_publish_policy" {
  name        = "SNSPublishPolicy"
  description = "Policy to allow SNS Publish for the new-user-topic"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sns:Publish",
        Resource = aws_sns_topic.new_user_topic.arn
      }
    ]
  })
}
resource "aws_iam_policy_attachment" "sns_publish_policy_attachment" {
  name       = "SNSPublishPolicyAttachment"
  roles      = [aws_iam_role.s3_access_role_to_ec2.name]
  policy_arn = aws_iam_policy.sns_publish_policy.arn
}
# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_exec_role" {
  name = "UserVerificationLambdaExecRole"

  # Allow Lambda to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

output "lambda_function_name" {
  value = aws_lambda_function.user_verification_lambda.function_name
}
resource "aws_sns_topic_subscription" "sns_lambda_subscription" {
  topic_arn = aws_sns_topic.new_user_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.user_verification_lambda.arn

  # Allow SNS to invoke the Lambda function
  depends_on = [aws_lambda_function.user_verification_lambda]
}
resource "aws_kms_key" "ec2_kms_key" {
  description             = "KMS key for EC2"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  rotation_period_in_days = 90
  multi_region            = true
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key_policy" "ec2_kms_key_policy" {
  key_id = aws_kms_key.ec2_kms_key.key_id
  policy = jsonencode({
    "Id" : "key-for-ebs",
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow access for Key Administrators",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow use of the key",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow attachment of persistent resources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : [
          "kms:CreateGrant",
          "kms:ListGrants",
          "kms:RevokeGrant"
        ],
        "Resource" : "*",
        "Condition" : {
          "Bool" : {
            "kms:GrantIsForAWSResource" : "true"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "ec2_kms_key_alias" {
  name          = "alias/EC2_Key"
  target_key_id = aws_kms_key.ec2_kms_key.key_id
}

resource "aws_kms_key" "rds_kms_key" {
  description             = "KMS key for RDS"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  rotation_period_in_days = 90
  multi_region            = true
}

resource "aws_kms_key_policy" "rds_kms_key_policy" {
  key_id = aws_kms_key.rds_kms_key.key_id
  policy = jsonencode({

    "Id" : "key-for-rds",
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow access for Key Administrators",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow access for RDS",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_kms_alias" "rds_kms_key_alias" {
  name          = "alias/RDSKey"
  target_key_id = aws_kms_key.rds_kms_key.key_id
}

resource "aws_kms_key" "s3_kms_key" {
  description             = "KMS_key_for_S3_bucket"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  rotation_period_in_days = 90
  multi_region            = true
}

resource "aws_kms_key_policy" "s3_kms_key_policy" {
  key_id = aws_kms_key.s3_kms_key.key_id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow access for Key Administrators",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow use of the key for S3",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_kms_alias" "s3_kms_key_alias" {
  name          = "alias/S3Key"
  target_key_id = aws_kms_key.s3_kms_key.key_id
}

# KMS Key for Secret Manager
resource "aws_kms_key" "secret_manager_key" {
  description             = "KMS key for Secret Manager"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  rotation_period_in_days = 90
  multi_region            = true
}

resource "aws_kms_key_policy" "secret_manager_key_policy" {
  key_id = aws_kms_key.secret_manager_key.id
  policy = jsonencode({
    "Id" : "key-for-ebs",
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Enable IAM User Permissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "Allow access for Key Administrators",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allow use of the key",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        },
        "Action" : [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      }
    ]
  })
}


resource "aws_kms_alias" "secret_manager_key_alias" {
  name          = "alias/SecretManager"
  target_key_id = aws_kms_key.secret_manager_key.key_id
}

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "db-password"
  kms_key_id              = aws_kms_key.secret_manager_key.arn
  recovery_window_in_days = 0
}

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%$!"
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({ password = random_password.db_password.result })
}


# Secret for SendGrid API Key
resource "aws_secretsmanager_secret" "sendgrid_api_key" {
  name                    = "sendgrid-api-key"
  kms_key_id              = aws_kms_key.secret_manager_key.arn
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "sendgrid_api_key_version" {
  secret_id     = aws_secretsmanager_secret.sendgrid_api_key.id
  secret_string = jsonencode({ SENDGRID_API_KEY = var.sendgrid_api_key })
}

# Secret for Domain
# resource "aws_secretsmanager_secret" "domain" {
#   name                    = "app-domain"
#   kms_key_id              = aws_kms_key.secret_manager_key.arn
#   recovery_window_in_days = 0
# }

# resource "aws_secretsmanager_secret_version" "domain_version" {
#   secret_id     = aws_secretsmanager_secret.domain.id
#   secret_string = jsonencode({ DOMAIN = "${var.env}${var.domain_name}" })
# }

# Lambda IAM Role Permissions to Access Secrets Manager
resource "aws_iam_policy" "lambda_secrets_access" {
  name        = "LambdaSecretsAccessPolicy"
  description = "Policy for Lambda to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = aws_secretsmanager_secret.sendgrid_api_key.arn
      },
      {
        Effect   = "Allow",
        Action   = "kms:Decrypt",
        Resource = aws_kms_key.secret_manager_key.arn
      }
    ]
  })
}


# Attach Secrets Manager Policy to Lambda Execution Role
resource "aws_iam_role_policy_attachment" "attach_lambda_secrets_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_secrets_access.arn
}

output "lambda_exec_role_policy_attachment" {
  value = aws_iam_role_policy_attachment.attach_lambda_secrets_access.policy_arn
}
