#!/bin/bash
# User data script for EKS Node Group

# Bootstrap the node to join the EKS cluster
/etc/eks/bootstrap.sh ${cluster_name}

# Install additional packages
yum update -y
yum install -y amazon-cloudwatch-agent

# Configure CloudWatch agent for EKS nodes
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
{
  "metrics": {
    "namespace": "CWAgent",
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
          "io_time"
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
            "log_group_name": "/aws/eks/${project_name}-${environment}/nodes",
            "log_stream_name": "{instance_id}-messages"
          },
          {
            "file_path": "/var/log/pods/**/*.log",
            "log_group_name": "/aws/eks/${project_name}-${environment}/pods",
            "log_stream_name": "{instance_id}-pods"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

echo "EKS node setup completed" > /var/log/eks-node-setup.log