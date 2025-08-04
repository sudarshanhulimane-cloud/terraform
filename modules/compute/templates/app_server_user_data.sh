#!/bin/bash

# Application Server User Data Script
# This script configures an application server for running web applications

set -e

# Update system
yum update -y

# Install additional packages
yum install -y \
    htop \
    vim \
    wget \
    curl \
    jq \
    unzip \
    git \
    docker \
    nginx \
    python3 \
    python3-pip

# Configure hostname
hostnamectl set-hostname ${hostname}

# Start and enable Docker
systemctl enable docker
systemctl start docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create application directory
mkdir -p /opt/app
cd /opt/app

# Create a simple web application
cat > /opt/app/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Application Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .status { padding: 20px; background: #f0f0f0; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Application Server</h1>
        <div class="status">
            <h2>Status: Running</h2>
            <p>Server: ${hostname}</p>
            <p>Timestamp: <span id="timestamp"></span></p>
        </div>
    </div>
    <script>
        document.getElementById('timestamp').textContent = new Date().toISOString();
    </script>
</body>
</html>
EOF

# Configure nginx
cat > /etc/nginx/conf.d/app.conf << 'EOF'
server {
    listen 80;
    server_name _;
    
    root /opt/app;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    location /health {
        access_log off;
        return 200 "OK\n";
        add_header Content-Type text/plain;
    }
    
    location /status {
        access_log off;
        return 200 "Server is running\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Remove default nginx configuration
rm -f /etc/nginx/conf.d/default.conf

# Start and enable nginx
systemctl enable nginx
systemctl start nginx

# Configure CloudWatch agent for monitoring
yum install -y amazon-cloudwatch-agent

# Create CloudWatch agent configuration
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/aws/ec2/app-server/messages",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/aws/ec2/app-server/nginx-access",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/aws/ec2/app-server/nginx-error",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "disk": {
        "measurement": ["used_percent"],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "mem": {
        "measurement": ["mem_used_percent"],
        "metrics_collection_interval": 60
      },
      "netstat": {
        "measurement": ["tcp_established", "tcp_listen"],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

# Start CloudWatch agent
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# Create a simple application service
cat > /etc/systemd/system/app.service << 'EOF'
[Unit]
Description=Application Server
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/app
ExecStart=/usr/bin/python3 -m http.server 8080
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the application service
systemctl enable app
systemctl start app

# Configure firewall (if needed)
# firewall-cmd --permanent --add-service=http
# firewall-cmd --permanent --add-service=https
# firewall-cmd --reload

# Set up log rotation
cat > /etc/logrotate.d/app << 'EOF'
/var/log/app.log {
    daily
    missingok
    rotate 7
    compress
    notifempty
    create 644 root root
}
EOF

# Create a simple monitoring script
cat > /opt/app/monitor.sh << 'EOF'
#!/bin/bash

# Simple monitoring script
echo "=== System Status ==="
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime)"
echo "Memory: $(free -h | grep Mem)"
echo "Disk: $(df -h / | tail -1)"
echo "Load: $(cat /proc/loadavg)"
echo "===================="
EOF

chmod +x /opt/app/monitor.sh

# Set up cron job for monitoring
echo "*/5 * * * * /opt/app/monitor.sh >> /var/log/app.log 2>&1" | crontab -

echo "Application server configuration completed successfully"