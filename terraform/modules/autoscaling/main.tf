}

# Launch Template
resource "aws_launch_template" "main" {
  name_prefix   = "${var.name}-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = var.security_group_ids

  user_data = base64encode(var.user_data)

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile != null ? [var.iam_instance_profile] : []
    content {
      name = iam_instance_profile.value
    }
  }

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name = block_device_mappings.value.device_name
      ebs {
        volume_size           = block_device_mappings.value.volume_size
        volume_type           = block_device_mappings.value.volume_type
        delete_on_termination = block_device_mappings.value.delete_on_termination
        encrypted             = block_device_mappings.value.encrypted
      }
    }
  }

  dynamic "network_interfaces" {
    for_each = var.associate_public_ip_address != null ? [1] : []
    content {
      associate_public_ip_address = var.associate_public_ip_address
      delete_on_termination       = true
      device_index               = 0
      security_groups            = var.security_group_ids
    }
  }

  dynamic "monitoring" {
    for_each = var.enable_monitoring ? [1] : []
    content {
      enabled = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = var.name
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = var.tags
  }

  tags = var.tags
}

# Auto Scaling Group
resource "aws_autoscaling_group" "main" {
  name                = var.name
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = var.target_group_arns
  health_check_type   = var.health_check_type
  health_check_grace_period = var.health_check_grace_period

  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  default_cooldown          = var.default_cooldown
  termination_policies      = var.termination_policies
  suspended_processes       = var.suspended_processes
  placement_group          = var.placement_group
  enabled_metrics          = var.enabled_metrics
  wait_for_capacity_timeout = var.wait_for_capacity_timeout
  protect_from_scale_in    = var.protect_from_scale_in

  launch_template {
    id      = aws_launch_template.main.id
    version = var.launch_template_version
  }

  dynamic "instance_refresh" {
    for_each = var.instance_refresh != null ? [var.instance_refresh] : []
    content {
      strategy = instance_refresh.value.strategy
      preferences {
        instance_warmup        = instance_refresh.value.instance_warmup
        min_healthy_percentage = instance_refresh.value.min_healthy_percentage
      }
      triggers = instance_refresh.value.triggers
    }
  }

  dynamic "warm_pool" {
    for_each = var.warm_pool != null ? [var.warm_pool] : []
    content {
      pool_state                  = warm_pool.value.pool_state
      min_size                   = warm_pool.value.min_size
      max_group_prepared_capacity = warm_pool.value.max_group_prepared_capacity
    }
  }

  tag {
    key                 = "Name"
    value               = var.name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = var.propagate_tags_at_launch
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Policies
resource "aws_autoscaling_policy" "scale_up" {
  count = var.enable_scale_up_policy ? 1 : 0

  name                   = "${var.name}-scale-up"
  scaling_adjustment     = var.scale_up_adjustment
  adjustment_type        = var.scale_up_adjustment_type
  cooldown              = var.scale_up_cooldown
  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type           = var.scale_up_policy_type

  dynamic "step_adjustment" {
    for_each = var.scale_up_policy_type == "StepScaling" ? var.scale_up_step_adjustments : []
    content {
      scaling_adjustment          = step_adjustment.value.scaling_adjustment
      metric_interval_lower_bound = step_adjustment.value.metric_interval_lower_bound
      metric_interval_upper_bound = step_adjustment.value.metric_interval_upper_bound
    }
  }

  dynamic "target_tracking_configuration" {
    for_each = var.scale_up_policy_type == "TargetTrackingScaling" ? [var.target_tracking_configuration] : []
    content {
      target_value = target_tracking_configuration.value.target_value
      
      dynamic "predefined_metric_specification" {
        for_each = target_tracking_configuration.value.predefined_metric_specification != null ? [target_tracking_configuration.value.predefined_metric_specification] : []
        content {
          predefined_metric_type = predefined_metric_specification.value.predefined_metric_type
          resource_label        = predefined_metric_specification.value.resource_label
        }
      }

      dynamic "customized_metric_specification" {
        for_each = target_tracking_configuration.value.customized_metric_specification != null ? [target_tracking_configuration.value.customized_metric_specification] : []
        content {
          metric_name = customized_metric_specification.value.metric_name
          namespace   = customized_metric_specification.value.namespace
          statistic   = customized_metric_specification.value.statistic
          
          dynamic "metric_dimension" {
            for_each = customized_metric_specification.value.dimensions
            content {
              name  = metric_dimension.value.name
              value = metric_dimension.value.value
            }
          }
        }
      }
    }
  }
}

resource "aws_autoscaling_policy" "scale_down" {
  count = var.enable_scale_down_policy ? 1 : 0

  name                   = "${var.name}-scale-down"
  scaling_adjustment     = var.scale_down_adjustment
  adjustment_type        = var.scale_down_adjustment_type
  cooldown              = var.scale_down_cooldown
  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type           = var.scale_down_policy_type

  dynamic "step_adjustment" {
    for_each = var.scale_down_policy_type == "StepScaling" ? var.scale_down_step_adjustments : []
    content {
      scaling_adjustment          = step_adjustment.value.scaling_adjustment
      metric_interval_lower_bound = step_adjustment.value.metric_interval_lower_bound
      metric_interval_upper_bound = step_adjustment.value.metric_interval_upper_bound
    }
  }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  count = var.enable_scale_up_policy ? 1 : 0

  alarm_name          = "${var.name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.high_cpu_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.high_cpu_period
  statistic           = "Average"
  threshold           = var.high_cpu_threshold
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_up[0].arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  count = var.enable_scale_down_policy ? 1 : 0

  alarm_name          = "${var.name}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.low_cpu_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.low_cpu_period
  statistic           = "Average"
  threshold           = var.low_cpu_threshold
  alarm_description   = "This metric monitors ec2 cpu utilization"
  alarm_actions       = [aws_autoscaling_policy.scale_down[0].arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

  tags = var.tags
}

# Auto Scaling Notifications
resource "aws_autoscaling_notification" "notifications" {
  count = var.enable_notifications ? 1 : 0

  group_names = [aws_autoscaling_group.main.name]

  notifications = var.notification_types

  topic_arn = var.notification_topic_arn
}