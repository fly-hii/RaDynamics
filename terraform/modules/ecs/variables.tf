# Terraform AWS ECS Module - Variables
# Comprehensive variable definitions for ECS module with security controls

variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  validation {
    condition     = length(var.cluster_name) > 0 && length(var.cluster_name) <= 255
    error_message = "Cluster name must be between 1 and 255 characters."
  }
}

variable "environment" {
  description = "Environment name (dev, qa, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, qa, test, staging, prod."
  }
}

# Cluster Configuration
variable "enable_container_insights" {
  description = "Enable CloudWatch Container Insights for the cluster"
  type        = bool
  default     = true
}

variable "enable_execute_command_logging" {
  description = "Enable execute command logging"
  type        = bool
  default     = true
}

variable "execute_command_kms_key_id" {
  description = "KMS key ID for execute command encryption"
  type        = string
  default     = null
}

variable "execute_command_log_group_name" {
  description = "CloudWatch log group name for execute command logging"
  type        = string
  default     = null
}

variable "execute_command_s3_bucket_name" {
  description = "S3 bucket name for execute command logging"
  type        = string
  default     = null
}

variable "execute_command_s3_key_prefix" {
  description = "S3 key prefix for execute command logging"
  type        = string
  default     = null
}

# Capacity Providers
variable "capacity_providers" {
  description = "List of capacity providers to associate with the cluster"
  type        = list(string)
  default     = ["FARGATE", "FARGATE_SPOT"]
}

variable "default_capacity_provider_strategy" {
  description = "Default capacity provider strategy for the cluster"
  type = list(object({
    capacity_provider = string
    weight           = number
    base             = number
  }))
  default = [
    {
      capacity_provider = "FARGATE"
      weight           = 1
      base             = 1
    }
  ]
}

variable "create_ec2_capacity_provider" {
  description = "Whether to create an EC2 capacity provider"
  type        = bool
  default     = false
}

variable "auto_scaling_group_arn" {
  description = "ARN of the Auto Scaling Group for EC2 capacity provider"
  type        = string
  default     = null
}

variable "managed_termination_protection" {
  description = "Enables or disables container-aware termination of instances"
  type        = string
  default     = "ENABLED"
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.managed_termination_protection)
    error_message = "Managed termination protection must be either 'ENABLED' or 'DISABLED'."
  }
}

variable "maximum_scaling_step_size" {
  description = "Maximum step adjustment size for managed scaling"
  type        = number
  default     = 1000
}

variable "minimum_scaling_step_size" {
  description = "Minimum step adjustment size for managed scaling"
  type        = number
  default     = 1
}

variable "managed_scaling_status" {
  description = "Whether managed scaling is enabled"
  type        = string
  default     = "ENABLED"
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.managed_scaling_status)
    error_message = "Managed scaling status must be either 'ENABLED' or 'DISABLED'."
  }
}

variable "target_capacity" {
  description = "Target utilization for the capacity provider"
  type        = number
  default     = 100
  validation {
    condition     = var.target_capacity >= 1 && var.target_capacity <= 100
    error_message = "Target capacity must be between 1 and 100."
  }
}

# Task Definition Configuration
variable "create_task_definition" {
  description = "Whether to create a task definition"
  type        = bool
  default     = true
}

variable "task_definition_family" {
  description = "Family name for the task definition"
  type        = string
  default     = null
}

variable "requires_compatibilities" {
  description = "Set of launch types required by the task"
  type        = list(string)
  default     = ["FARGATE"]
  validation {
    condition = alltrue([
      for compat in var.requires_compatibilities : contains(["EC2", "FARGATE"], compat)
    ])
    error_message = "Requires compatibilities must contain only 'EC2' and/or 'FARGATE'."
  }
}

variable "network_mode" {
  description = "Network mode to use for the containers in the task"
  type        = string
  default     = "awsvpc"
  validation {
    condition     = contains(["none", "bridge", "awsvpc", "host"], var.network_mode)
    error_message = "Network mode must be one of: none, bridge, awsvpc, host."
  }
}

variable "task_cpu" {
  description = "Number of CPU units used by the task"
  type        = string
  default     = "256"
}

variable "task_memory" {
  description = "Amount of memory (in MiB) used by the task"
  type        = string
  default     = "512"
}

variable "execution_role_arn" {
  description = "ARN of the task execution role"
  type        = string
  default     = null
}

variable "task_role_arn" {
  description = "ARN of the task role"
  type        = string
  default     = null
}

# Container Definitions
variable "container_definitions" {
  description = "List of container definitions"
  type = list(object({
    name      = string
    image     = string
    cpu       = number
    memory    = number
    essential = bool

    port_mappings = list(object({
      container_port = number
      host_port      = number
      protocol       = string
    }))

    environment = list(object({
      name  = string
      value = string
    }))

    secrets = list(object({
      name       = string
      value_from = string
    }))

    log_configuration = object({
      log_driver = string
      options    = map(string)
    })

    health_check = object({
      command     = list(string)
      interval    = number
      timeout     = number
      retries     = number
      start_period = number
    })

    # Security Configuration
    readonly_root_filesystem = bool
    privileged              = bool
    user                    = string

    linux_parameters = object({
      capabilities = object({
        add  = list(string)
        drop = list(string)
      })
      devices = list(object({
        host_path      = string
        container_path = string
        permissions    = list(string)
      }))
      init_process_enabled = bool
      max_swap            = number
      swappiness          = number
      tmpfs = list(object({
        container_path = string
        size          = number
        mount_options  = list(string)
      }))
    })

    mount_points = list(object({
      source_volume  = string
      container_path = string
      read_only      = bool
    }))

    volumes_from = list(object({
      source_container = string
      read_only       = bool
    }))
  }))
  default = []
}

# Volume Configuration
variable "volumes" {
  description = "List of volume definitions"
  type = list(object({
    name      = string
    host_path = string

    docker_volume_configuration = object({
      scope         = string
      autoprovision = bool
      driver        = string
      driver_opts   = map(string)
      labels        = map(string)
    })

    efs_volume_configuration = object({
      file_system_id          = string
      root_directory          = string
      transit_encryption      = string
      transit_encryption_port = number
      authorization_config = object({
        access_point_id = string
        iam            = string
      })
    })

    fsx_windows_file_server_volume_configuration = object({
      file_system_id = string
      root_directory = string
      authorization_config = object({
        credentials_parameter = string
        domain               = string
      })
    })
  }))
  default = []
}

# Placement Constraints
variable "placement_constraints" {
  description = "Rules that are taken into consideration during task placement"
  type = list(object({
    type       = string
    expression = string
  }))
  default = []
}

# Proxy Configuration
variable "proxy_configuration" {
  description = "Proxy configuration for the container"
  type = object({
    type           = string
    container_name = string
    properties     = map(string)
  })
  default = null
}

# Inference Accelerators
variable "inference_accelerators" {
  description = "Inference accelerators for the task"
  type = list(object({
    device_name = string
    device_type = string
  }))
  default = []
}

# Service Configuration
variable "create_service" {
  description = "Whether to create an ECS service"
  type        = bool
  default     = true
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
  default     = null
}

variable "existing_task_definition_arn" {
  description = "ARN of existing task definition to use"
  type        = string
  default     = null
}

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running"
  type        = number
  default     = 1
}

variable "launch_type" {
  description = "Launch type on which to run your service"
  type        = string
  default     = "FARGATE"
  validation {
    condition     = contains(["EC2", "FARGATE", "EXTERNAL"], var.launch_type)
    error_message = "Launch type must be one of: EC2, FARGATE, EXTERNAL."
  }
}

variable "platform_version" {
  description = "Platform version on which to run your service"
  type        = string
  default     = "LATEST"
}

variable "scheduling_strategy" {
  description = "Scheduling strategy to use for the service"
  type        = string
  default     = "REPLICA"
  validation {
    condition     = contains(["REPLICA", "DAEMON"], var.scheduling_strategy)
    error_message = "Scheduling strategy must be either 'REPLICA' or 'DAEMON'."
  }
}

variable "enable_execute_command" {
  description = "Enable execute command functionality for the containers in this service"
  type        = bool
  default     = false
}

variable "enable_ecs_managed_tags" {
  description = "Enable ECS managed tags for the tasks in the service"
  type        = bool
  default     = true
}

variable "propagate_tags" {
  description = "Specifies whether to propagate the tags from the task definition or the service"
  type        = string
  default     = "SERVICE"
  validation {
    condition     = contains(["TASK_DEFINITION", "SERVICE", "NONE"], var.propagate_tags)
    error_message = "Propagate tags must be one of: TASK_DEFINITION, SERVICE, NONE."
  }
}

variable "health_check_grace_period_seconds" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks"
  type        = number
  default     = null
}

# Service Capacity Provider Strategy
variable "service_capacity_provider_strategy" {
  description = "Capacity provider strategy for the service"
  type = list(object({
    capacity_provider = string
    weight           = number
    base             = number
  }))
  default = []
}

# Network Configuration
variable "network_configuration" {
  description = "Network configuration for the service"
  type = object({
    subnets          = list(string)
    security_groups  = list(string)
    assign_public_ip = bool
  })
  default = null
}

# Load Balancer Configuration
variable "load_balancers" {
  description = "Load balancer configuration for the service"
  type = list(object({
    target_group_arn = string
    container_name   = string
    container_port   = number
  }))
  default = []
}

# Service Discovery
variable "service_registries" {
  description = "Service discovery registries for the service"
  type = list(object({
    registry_arn   = string
    port          = number
    container_name = string
    container_port = number
  }))
  default = []
}

# Service Placement
variable "service_placement_constraints" {
  description = "Rules that are taken into consideration during task placement"
  type = list(object({
    type       = string
    expression = string
  }))
  default = []
}

variable "ordered_placement_strategy" {
  description = "Service level strategy rules that are taken into consideration during task placement"
  type = list(object({
    type  = string
    field = string
  }))
  default = []
}

# Deployment Configuration
variable "deployment_configuration" {
  description = "Deployment configuration for the service"
  type = object({
    maximum_percent         = number
    minimum_healthy_percent = number
    deployment_circuit_breaker = object({
      enable   = bool
      rollback = bool
    })
  })
  default = null
}

variable "deployment_controller" {
  description = "Deployment controller configuration"
  type = object({
    type = string
  })
  default = null
}

# CloudWatch Configuration
variable "create_cloudwatch_log_group" {
  description = "Whether to create a CloudWatch log group"
  type        = bool
  default     = true
}

variable "log_retention_in_days" {
  description = "Specifies the number of days you want to retain log events"
  type        = number
  default     = 30
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.log_retention_in_days)
    error_message = "Log retention must be a valid CloudWatch Logs retention period."
  }
}

variable "log_group_kms_key_id" {
  description = "KMS key ID for log group encryption"
  type        = string
  default     = null
}

variable "enable_cloudwatch_alarms" {
  description = "Whether to create CloudWatch alarms"
  type        = bool
  default     = true
}

variable "cpu_utilization_threshold" {
  description = "CPU utilization threshold for CloudWatch alarm"
  type        = number
  default     = 80
  validation {
    condition     = var.cpu_utilization_threshold >= 1 && var.cpu_utilization_threshold <= 100
    error_message = "CPU utilization threshold must be between 1 and 100."
  }
}

variable "memory_utilization_threshold" {
  description = "Memory utilization threshold for CloudWatch alarm"
  type        = number
  default     = 80
  validation {
    condition     = var.memory_utilization_threshold >= 1 && var.memory_utilization_threshold <= 100
    error_message = "Memory utilization threshold must be between 1 and 100."
  }
}

variable "alarm_actions" {
  description = "List of alarm actions"
  type        = list(string)
  default     = []
}

# Security Configuration
variable "require_encryption" {
  description = "Whether to require encryption for logs and data"
  type        = bool
  default     = true
}

variable "enable_encryption" {
  description = "Whether to enable encryption"
  type        = bool
  default     = true
}

variable "enable_logging" {
  description = "Whether to enable logging"
  type        = bool
  default     = true
}

variable "security_controls_enabled" {
  description = "Whether to enable security controls validation"
  type        = bool
  default     = true
}

variable "security_compliance_tags" {
  description = "Security compliance tags"
  type        = map(string)
  default     = {}
}

variable "additional_tags" {
  description = "Additional tags to be merged with core tags"
  type        = map(string)
  default     = {}
}

# CCMS compliance variables
variable "cost_center" {
  description = "Cost center for billing and resource allocation"
  type        = string
  default     = "default-cost-center"
}

variable "project_name" {
  description = "Project name for resource organization"
  type        = string
  default     = "ecs-project"
}

variable "owner" {
  description = "Resource owner for accountability"
  type        = string
  default     = "terraform-user"
}

variable "business_unit" {
  description = "Business unit responsible for the resource"
  type        = string
  default     = "engineering"
}

variable "application_name" {
  description = "Application name for resource categorization"
  type        = string
  default     = "ecs-application"
}

variable "data_classification" {
  description = "Data classification level"
  type        = string
  default     = "internal"
  validation {
    condition     = contains(["public", "internal", "confidential", "restricted"], var.data_classification)
    error_message = "Data classification must be one of: public, internal, confidential, restricted."
  }
}