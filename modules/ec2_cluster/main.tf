resource "aws_launch_template" "webapp" {
  name_prefix   = "webapp-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.security_group_id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              echo "<h1>Hello from EC2 in ASG</h1>" > /var/www/html/index.html
              systemctl start httpd
              systemctl enable httpd
            EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "webapp-ec2"
    }
  }
  iam_instance_profile {
    name = var.instance_profile_name
  }

}

resource "aws_autoscaling_group" "webapp_asg" {
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.subnet_ids
  launch_template {
    id      = aws_launch_template.webapp.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "webapp-instance"
    propagate_at_launch = true
  }

  health_check_type         = "EC2"
  force_delete              = true
  wait_for_capacity_timeout = "0"
  target_group_arns = var.target_group_arn != null ? [var.target_group_arn] : null
}

