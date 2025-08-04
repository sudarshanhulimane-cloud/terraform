#!/bin/bash

# Bastion Host User Data Script
# This script configures a bastion host for secure SSH access

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
    git

# Configure hostname
hostnamectl set-hostname ${hostname}

# Configure SSH
cat > /etc/ssh/sshd_config.d/bastion.conf << 'EOF'
# Bastion host SSH configuration
Port 22
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
UsePrivilegeSeparation yes
KeyRegenerationInterval 3600
ServerKeyBits 1024
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin no
StrictModes yes
RSAAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
PasswordAuthentication no
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
AcceptEnv LANG LC_*
Subsystem sftp /usr/libexec/openssh/sftp-server
UsePAM yes
EOF

# Restart SSH service
systemctl restart sshd

# Create admin user (optional)
# useradd -m -s /bin/bash admin
# usermod -aG wheel admin

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
            "log_group_name": "/aws/ec2/bastion/messages",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/secure",
            "log_group_name": "/aws/ec2/bastion/secure",
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
      }
    }
  }
}
EOF

# Start CloudWatch agent
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# Create a simple health check endpoint
cat > /var/www/html/health << 'EOF'
OK
EOF

# Install and configure nginx for health checks
yum install -y nginx
systemctl enable nginx
systemctl start nginx

# Configure nginx for health checks
cat > /etc/nginx/conf.d/health.conf << 'EOF'
server {
    listen 80;
    server_name _;
    
    location /health {
        alias /var/www/html/health;
        access_log off;
    }
    
    location / {
        return 403;
    }
}
EOF

# Reload nginx
systemctl reload nginx

# Set up log rotation
cat > /etc/logrotate.d/bastion << 'EOF'
/var/log/bastion.log {
    daily
    missingok
    rotate 7
    compress
    notifempty
    create 644 root root
}
EOF

echo "Bastion host configuration completed successfully"