# Fetch latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.*-x86_64-gp2"]
  }
}

resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Allow web from ALB and SSH from user (optional)"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_sg_id] # allow from ALB SG
    description     = "from alb"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidrs
    description = "ssh"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "web" {
  name_prefix   = "web-lt-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = var.key_name != "" ? var.key_name : null

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.instance_sg.id]
  }

  user_data = base64encode(templatefile("${path.module}/userdata.tpl", {
    index_message = var.index_message
  }))

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "demo-web-instance"
    }
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = "demo-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  health_check_type         = "EC2"
  vpc_zone_identifier       = var.subnet_ids
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
  target_group_arns = [var.target_group_arn]

  tag {
    key                 = "Name"
    value               = "demo-asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Target tracking scaling policy - keep average CPU around target
resource "aws_autoscaling_policy" "predictive_scaling" {
  name                   = "predictive-scaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  policy_type            = "PredictiveScaling"

  predictive_scaling_configuration {
    metric_specification {
      target_value = 100000.0   # ✔ REQUIRED FOR PREDICTIVE SCALING

      predefined_load_metric_specification {
        predefined_metric_type = "ALBRequestCountPerTarget"
        resource_label         = var.resource_label
      }

      predefined_metric_pair_specification {
        predefined_metric_type = "ALBRequestCountPerTarget"
        resource_label         = var.resource_label
      }

      predefined_scaling_metric_specification {
        predefined_metric_type = "ALBRequestCountPerTarget"
        resource_label         = var.resource_label
      }
    }

    mode                        = "ForecastOnly"   # or "ForecastAndScale"
    scheduling_buffer_time      = 300              # seconds
    max_capacity_breach_behavior = "HonorMaxCapacity"
    max_capacity_buffer          = 0
  }
}
