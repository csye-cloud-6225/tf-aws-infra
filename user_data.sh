#!/bin/bash
# Create logs directory if it doesn't exist
sudo mkdir -p /opt/webapp/logs
 
# Create the cloudwatch group and add users
sudo groupadd cloudwatch || true
sudo usermod -aG cloudwatch csye6225
sudo usermod -aG cloudwatch cloudwatch-agent
 
# Set ownership and permissions for the logs directory
sudo chown -R csye6225:cloudwatch /opt/webapp/logs
sudo chmod -R 775 /opt/webapp/logs
sudo chmod g+s /opt/webapp/logs
 
# Copy the CloudWatch Agent configuration file to the appropriate location
sudo cp /opt/webapp/src/config/cloudwatch-config.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
 
# Configure CloudWatch Agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
 
# Create the .env file with database environment variables and AWS credentials
cat <<EOT > /opt/webapp/.env
DB_HOST="${DB_HOST}"
DB_USER="${DB_USER}"
DB_PASSWORD="${DB_PASSWORD}"
DB_NAME="${DB_NAME}"
DB_PORT="${DB_PORT}"
NODE_ENV="${NODE_ENV}"
S3_BUCKET_NAME="${S3_BUCKET_NAME}"
AWS_REGION="${AWS_REGION}"
AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
SNS_TOPIC_ARN="${SNS_TOPIC_ARN}"
 
EOT
 
echo "DB_PASSWORD=${DB_PASSWORD}" >> /opt/webapp/logs/user_data_debug.log
 
 
# Set permissions for the .env file to ensure it's accessible by the webapp user
sudo chown csye6225:csye6225 /opt/webapp/.env
sudo chmod 600 /opt/webapp/.env
 
# Restart the web application to pick up the new environment variables
sudo systemctl daemon-reload
sudo systemctl enable webapp.service
sudo systemctl start webapp.service
 
has context menu