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
  password               = var.db_password
  parameter_group_name   = aws_db_parameter_group.my_db_parameter_group.name

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
      sse_algorithm = "AES256"
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

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.app_sg.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "DB_HOST=${aws_db_instance.my_database.address}" >> /etc/environment
    echo "DB_USER=${var.db_username}" >> /etc/environment
    echo "DB_NAME=${var.db_name}" >> /etc/environment
    echo "DB_PORT=${var.db_port}" >> /etc/environment
    echo "DB_PASSWORD=${var.db_password}" >> /etc/environment
    echo "aws_region=${var.aws_region}" >> /etc/environment
    echo "bucket_name=${aws_s3_bucket.private_webapp_bucket.bucket}" >> /etc/environment
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
resource "aws_lb_listener" "web_app_listener" {
  load_balancer_arn = aws_lb.web_app_alb.arn
  port              = 80
  protocol          = "HTTP"

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
