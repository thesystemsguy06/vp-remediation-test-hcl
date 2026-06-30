# Auto Scaling resources with intentionally non-compliant configurations
# Wave 3 — Launch templates are free, ASGs are free (instances cost in Wave 4)
#
# Triggered controls:
#   AutoScaling.1  — ASGs associated with a load balancer should use health checks
#   AutoScaling.2  — ASG should cover multiple AZs
#   AutoScaling.3  — ASG launch configurations should configure instances to require IMDSv2
#   AutoScaling.6  — ASGs should use multiple instance types in multiple AZs
#   AutoScaling.9  — ASGs should use launch templates (not launch configs)
#   EC2.25 — Launch templates should not assign public IPs
#   EC2.170 — Launch templates should use IMDSv2

# Launch template — no IMDSv2, assigns public IP
resource "aws_launch_template" "vp_test" {
  name = "vp-test-insecure-lt"

  image_id      = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = true
    # associate_public_ip_address = true — triggers EC2.25
  }

  # No metadata_options block — triggers EC2.170, AutoScaling.3
  # Should have: metadata_options { http_tokens = "required" }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "vp-e2e-test-instance"
    })
  }

  tags = var.common_tags
}

# Launch configuration (legacy) — triggers AutoScaling.9
resource "aws_launch_configuration" "vp_test" {
  name_prefix   = "vp-test-insecure-lc-"
  image_id      = "ami-0c02fb55956c7d316"
  instance_type = "t3.micro"

  # Using launch config instead of template — triggers AutoScaling.9

  lifecycle {
    create_before_destroy = true
  }
}

# ASG — single AZ, no health check, uses launch config
# NOTE: ASG with instances will incur costs. Commented out by default.
#
# resource "aws_autoscaling_group" "vp_test" {
#   name                = "vp-test-insecure-asg"
#   launch_configuration = aws_launch_configuration.vp_test.name
#   min_size            = 0
#   max_size            = 1
#   desired_capacity    = 0
#   vpc_zone_identifier = [var.private_subnet_a_id]
#
#   # Single AZ — triggers AutoScaling.2
#   # No health_check_type = "ELB" — triggers AutoScaling.1 (when attached to LB)
#   # Uses launch_configuration — triggers AutoScaling.9
#   # Single instance type — triggers AutoScaling.6
#
#   tag {
#     key                 = "ManagedBy"
#     value               = "vectorplane-e2e-test"
#     propagate_at_launch = true
#   }
# }
