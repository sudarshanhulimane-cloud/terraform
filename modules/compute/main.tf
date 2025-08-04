# Compute Module - EC2 Instances, Bastion Host, and Auto Scaling Group

# Data sources
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

# Bastion Host
resource "aws_instance" "bastion" {
  count = var.enable_bastion ? 1 : 0

  ami                    = var.bastion_ami_id != null ? var.bastion_ami_id : data.aws_ami.amazon_linux.id
  instance_type          = var.bastion_instance_type
  key_name              = var.bastion_key_name
  vpc_security_group_ids = [var.bastion_security_group_id]
  subnet_id             = var.public_subnet_ids[0]

  user_data = templatefile("${path.module}/templates/bastion_user_data.sh", {
    hostname = "bastion-${var.name}"
  })

  tags = merge(var.tags, {
    Name = "bastion-${var.name}"
    Role = "bastion"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Application EC2 Instance
resource "aws_instance" "app_server" {
  count = var.enable_app_server ? var.app_server_count : 0

  ami                    = var.app_server_ami_id != null ? var.app_server_ami_id : data.aws_ami.amazon_linux.id
  instance_type          = var.app_server_instance_type
  key_name              = var.app_server_key_name
  vpc_security_group_ids = [var.app_server_security_group_id]
  subnet_id             = var.private_subnet_ids[count.index % length(var.private_subnet_ids)]
  iam_instance_profile   = var.app_server_iam_instance_profile

  user_data = templatefile("${path.module}/templates/app_server_user_data.sh", {
    hostname = "app-server-${count.index + 1}-${var.name}"
  })

  root_block_device {
    volume_size = var.app_server_root_volume_size
    volume_type = var.app_server_root_volume_type
    encrypted   = true
  }

  tags = merge(var.tags, {
    Name = "app-server-${count.index + 1}-${var.name}"
    Role = "application"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Launch Template for Auto Scaling Group
resource "aws_launch_template" "app" {
  count = var.enable_auto_scaling_group ? 1 : 0

  name_prefix   = "app-${var.name}-"
  image_id      = var.app_server_ami_id != null ? var.app_server_ami_id : data.aws_ami.amazon_linux.id
  instance_type = var.app_server_instance_type
  key_name      = var.app_server_key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups            = [var.app_server_security_group_id]
  }

  iam_instance_profile {
    name = var.app_server_iam_instance_profile
  }

  user_data = base64encode(templatefile("${path.module}/templates/app_server_user_data.sh", {
    hostname = "app-asg-${var.name}"
  }))

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.app_server_root_volume_size
      volume_type = var.app_server_root_volume_type
      encrypted   = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "app-asg-${var.name}"
      Role = "application"
    })
  }

  tags = merge(var.tags, {
    Name = "app-launch-template-${var.name}"
  })
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app" {
  count = var.enable_auto_scaling_group ? 1 : 0

  name                = "app-asg-${var.name}"
  desired_capacity    = var.asg_desired_capacity
  max_size           = var.asg_max_size
  min_size           = var.asg_min_size
  target_group_arns  = var.target_group_arns
  vpc_zone_identifier = var.private_subnet_ids
  health_check_type  = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.app[0].id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value              = "app-asg-${var.name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Role"
    value              = "application"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value              = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Policy
resource "aws_autoscaling_policy" "cpu" {
  count = var.enable_auto_scaling_group && var.enable_cpu_scaling ? 1 : 0

  name                   = "cpu-scaling-policy-${var.name}"
  scaling_adjustment     = var.cpu_scaling_adjustment
  adjustment_type        = "ChangeInCapacity"
  cooldown              = var.cpu_scaling_cooldown
  autoscaling_group_name = aws_autoscaling_group.app[0].name
}

# CloudWatch CPU Alarm for Auto Scaling
resource "aws_cloudwatch_metric_alarm" "cpu" {
  count = var.enable_auto_scaling_group && var.enable_cpu_scaling ? 1 : 0

  alarm_name          = "cpu-utilization-${var.name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "CPUUtilization"
  namespace          = "AWS/EC2"
  period             = "120"
  statistic          = "Average"
  threshold          = var.cpu_threshold
  alarm_description  = "This metric monitors EC2 CPU utilization"
  alarm_actions      = [aws_autoscaling_policy.cpu[0].arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app[0].name
  }
}