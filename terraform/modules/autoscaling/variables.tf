variable "name" {
  description = "Name of the Auto Scaling Group"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the launch template"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the launch template"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Key name for EC2 instances"
  type        = string
  default     = null
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Auto Scaling Group"
  type        = list(string)
}

variable "user_data" {
  description = "User data script for instances"
  type        = string
  default     = ""
}

variable "iam_instance_profile" {
  description = "IAM instance profile name"
  type        = string
  default     = null
}

variable "associate_public_ip_address" {
  description = "Associate public IP address"
  type        = bool
  default     = null
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "block_device_mappings" {
  description = "Block device mappings for the launch template"
  type = list(object({
    device_name           = string
    volume_size          = number
    volume_type          = string
    delete_on_termination = bool
    encrypted            = bool
  }))
  default = [{
    device_name           = "/dev/xvda"
    volume_size          = 8
    volume_type          = "gp3"
    delete_on_termination = true
    encrypted            = false
  }]
}

# Auto Scaling Group variables
variable "min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "target_group_arns" {
  description = "List of target group ARNs for load balancer"
  type        = list(string)
  default     = []
}

variable "health_check_type" {
  description = "Health check type (EC2 or ELB)"
  type        = string
  default     = "EC2"
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 300
}

variable "default_cooldown" {
  description = "Default cooldown period in seconds"
  type        = number
  default     = 300
}

variable "termination_policies" {
  description = "List of termination policies"
  type        = list(string)
  default     = ["Default"]
}

variable "suspended_processes" {
  description = "List of suspended processes"
  type        = list(string)
  default     = []
}

variable "placement_group" {
  description = "Placement group name"
  type        = string
  default     = null
}

variable "enabled_metrics" {
  description = "List of enabled metrics"
  type        = list(string)
  default     = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
}

variable "wait_for_capacity_timeout" {
  description = "Maximum duration to wait for capacity"
  type        = string
  default     = "10m"
}

variable "protect_from_scale_in" {
  description = "Protect instances from scale in"
  type        = bool
  default     = false
}

variable "launch_template_version" {
  description = "Launch template version"
  type        = string
  default     = "$Latest"
}

variable "propagate_tags_at_launch" {
  description = "Propagate tags at launch"
  type        = bool
  default     = true
}

# Instance Refresh
variable "instance_refresh" {
  description = "Instance refresh configuration"
  type = object({
    strategy               = string
    instance_warmup        = number
    min_healthy_percentage = number
    triggers              = list(string)
  })
  default = null
}

# Warm Pool
variable "warm_pool" {
  description = "Warm pool configuration"
  type = object({
    pool_state                  = string
    min_size                   = number
    max_group_prepared_capacity = number
  })
  default = null
}

# Scaling Policies
variable "enable_scale_up_policy" {
  description = "Enable scale up policy"
  type        = bool
  default     = true
}

variable "enable_scale_down_policy" {
  description = "Enable scale down policy"
  type        = bool
  default     = true
}

variable "scale_up_adjustment" {
  description = "Scale up adjustment"
  type        = number
  default     = 1
}

variable "scale_up_adjustment_type" {
  description = "Scale up adjustment type"
  type        = string
  default     = "ChangeInCapacity"
}

variable "scale_up_cooldown" {
  description = "Scale up cooldown period"
  type        = number
  default     = 300
}

variable "scale_up_policy_type" {
  description = "Scale up policy type"
  type        = string
  default     = "SimpleScaling"
}

variable "scale_down_adjustment" {
  description = "Scale down adjustment"
  type        = number
  default     = -1
}

variable "scale_down_adjustment_type" {
  description = "Scale down adjustment type"
  type        = string
  default     = "ChangeInCapacity"
}

variable "scale_down_cooldown" {
  description = "Scale down cooldown period"
  type        = number
  default     = 300
}

variable "scale_down_policy_type" {
  description = "Scale down policy type"
  type        = string
  default     = "SimpleScaling"
}

# Step Scaling
variable "scale_up_step_adjustments" {
  description = "Step adjustments for scale up policy"
  type = list(object({
    scaling_adjustment          = number
    metric_interval_lower_bound = number
    metric_interval_upper_bound = number
  }))
  default = []
}

variable "scale_down_step_adjustments" {
  description = "Step adjustments for scale down policy"
  type = list(object({
    scaling_adjustment          = number
    metric_interval_lower_bound = number
    metric_interval_upper_bound = number
  }))
  default = []
}

# Target Tracking
variable "target_tracking_configuration" {
  description = "Target tracking configuration"
  type = object({
    target_value = number
    predefined_metric_specification = object({
      predefined_metric_type = string
      resource_label        = string
    })
    customized_metric_specification = object({
      metric_name = string
      namespace   = string
      statistic   = string
      dimensions = list(object({
        name  = string
        value = string
      }))
    })
  })
  default = null
}

# CloudWatch Alarms
variable "high_cpu_threshold" {
  description = "High CPU threshold for scaling up"
  type        = number
  default     = 80
}

variable "high_cpu_evaluation_periods" {
  description = "High CPU evaluation periods"
  type        = number
  default     = 2
}

variable "high_cpu_period" {
  description = "High CPU period in seconds"
  type        = number
  default     = 120
}

variable "low_cpu_threshold" {
  description = "Low CPU threshold for scaling down"
  type        = number
  default     = 10
}

variable "low_cpu_evaluation_periods" {
  description = "Low CPU evaluation periods"
  type        = number
  default     = 2
}

variable "low_cpu_period" {
  description = "Low CPU period in seconds"
  type        = number
  default     = 120
}

# Notifications
variable "enable_notifications" {
  description = "Enable Auto Scaling notifications"
  type        = bool
  default     = false
}

variable "notification_topic_arn" {
  description = "SNS topic ARN for notifications"
  type        = string
  default     = ""
}

variable "notification_types" {
  description = "List of notification types"
  type        = list(string)
  default = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}