#!/bin/bash
# User data script for Application Servers

# Update system
yum update -y

# Install essential packages
yum install -y wget curl git htop tree

# Install Docker
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install Node.js (example application runtime)
curl -sL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Install Nginx
amazon-linux-extras install nginx1 -y
systemctl start nginx
systemctl enable nginx

# Configure Nginx for health checks
cat <<EOF > /etc/nginx/conf.d/health.conf
server {
    listen 80;
    location /health {
        return 200 'OK';
        add_header Content-Type text/plain;
    }
}
EOF

systemctl restart nginx

# Configure CloudWatch agent
yum install -y amazon-cloudwatch-agent
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "metrics": {
    "namespace": "AWS/EC2/Custom",
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_iowait",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": 60,
        "totalcpu": false
      },
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "diskio": {
        "measurement": [
          "io_time",
          "read_bytes",
          "write_bytes",
          "reads",
          "writes"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/aws/ec2/${project_name}-${environment}-app",
            "log_stream_name": "{instance_id}-messages"
          },
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/aws/ec2/${project_name}-${environment}-nginx",
            "log_stream_name": "{instance_id}-access"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/aws/ec2/${project_name}-${environment}-nginx",
            "log_stream_name": "{instance_id}-error"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# Create a simple health check endpoint
mkdir -p /var/www/html
echo "OK" > /var/www/html/health

echo "Application server setup completed" > /var/log/user-data-setup.log