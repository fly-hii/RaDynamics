# Local implementation of tags data (replaces external CCMS module)
locals {
  # Core tags following CCMS standards
  core_tags = {
    CreatedBy     = "terraform"
    ManagedBy     = "terraform-aws-ecs-module"
    CreatedDate   = formatdate("YYYY-MM-DD", timestamp())
    LastModified  = formatdate("YYYY-MM-DD", timestamp())
    CostCenter    = var.cost_center
    Project       = var.project_name
    Owner         = var.owner
    BusinessUnit  = var.business_unit
    Application   = var.application_name
    DataClass     = var.data_classification
    Compliance    = "CCMS"
  }
}

# Local implementation of config validation
locals {
  # Configuration constants and validation
  config = {
    # Security requirements by environment
    security_requirements = {
      encryption_required     = var.environment == "prod" ? true : var.require_encryption
      logging_required       = var.environment == "prod" ? true : var.enable_logging
      insights_required      = var.environment == "prod" ? true : var.enable_container_insights
      execute_command_audit  = var.environment == "prod" ? true : var.enable_execute_command_logging
    }
  }
}

# Standard tags following CCMS requirements with Security Controls
locals {
  standard_tags = merge(
    local.core_tags,
    {
      Name        = var.cluster_name
      Module      = "terraform-aws-l1-ecs"
      Environment = var.environment
      Component   = "ecs-cluster"
      # Security Control ECS-01: Container Security
      SecurityControls         = "ECS-01,ECS-02,ECS-03,ECS-04,ECS-05"
      EncryptionEnabled        = var.enable_encryption ? "true" : "false"
      ContainerInsightsEnabled = var.enable_container_insights ? "true" : "false"
      ExecuteCommandLogging    = var.enable_execute_command_logging ? "true" : "false"
    },
    var.security_compliance_tags,
    var.additional_tags
  )
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = var.cluster_name

  # Container Insights (Security Control ECS-02: Monitoring and Logging)
  dynamic "setting" {
    for_each = var.enable_container_insights ? [1] : []
    content {
      name  = "containerInsights"
      value = "enabled"
    }
  }

  # Cluster Configuration
  dynamic "configuration" {
    for_each = var.enable_execute_command_logging || var.enable_encryption ? [1] : []
    content {
      # Execute Command Configuration (Security Control ECS-03: Command Execution Logging)
      dynamic "execute_command_configuration" {
        for_each = var.enable_execute_command_logging ? [1] : []
        content {
          kms_key_id = var.execute_command_kms_key_id
          logging    = "OVERRIDE"

          log_configuration {
            cloud_watch_encryption_enabled = var.enable_encryption
            cloud_watch_log_group_name     = var.execute_command_log_group_name
            s3_bucket_name                 = var.execute_command_s3_bucket_name
            s3_bucket_encryption_enabled   = var.enable_encryption
            s3_key_prefix                  = var.execute_command_s3_key_prefix
          }
        }
      }
    }
  }

  tags = local.standard_tags
}

# ECS Cluster Capacity Providers
resource "aws_ecs_cluster_capacity_providers" "main" {
  count = length(var.capacity_providers) > 0 ? 1 : 0

  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = var.capacity_providers

  dynamic "default_capacity_provider_strategy" {
    for_each = var.default_capacity_provider_strategy
    content {
      capacity_provider = default_capacity_provider_strategy.value.capacity_provider
      weight           = default_capacity_provider_strategy.value.weight
      base             = default_capacity_provider_strategy.value.base
    }
  }
}

# Auto Scaling Group Capacity Provider (for EC2 launch type)
resource "aws_ecs_capacity_provider" "ec2" {
  count = var.create_ec2_capacity_provider ? 1 : 0

  name = "${var.cluster_name}-ec2-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = var.auto_scaling_group_arn
    managed_termination_protection = var.managed_termination_protection

    managed_scaling {
      maximum_scaling_step_size = var.maximum_scaling_step_size
      minimum_scaling_step_size = var.minimum_scaling_step_size
      status                   = var.managed_scaling_status
      target_capacity          = var.target_capacity
    }
  }

  tags = local.standard_tags
}

# ECS Task Definition
resource "aws_ecs_task_definition" "main" {
  count = var.create_task_definition ? 1 : 0

  family                   = var.task_definition_family
  requires_compatibilities = var.requires_compatibilities
  network_mode            = var.network_mode
  cpu                     = var.task_cpu
  memory                  = var.task_memory
  execution_role_arn      = var.execution_role_arn
  task_role_arn           = var.task_role_arn

  # Container Definitions (Security Control ECS-01: Container Security)
  container_definitions = jsonencode([
    for container in var.container_definitions : {
      name      = container.name
      image     = container.image
      cpu       = container.cpu
      memory    = container.memory
      essential = container.essential

      # Port Mappings
      portMappings = [
        for port in container.port_mappings : {
          containerPort = port.container_port
          hostPort      = port.host_port
          protocol      = port.protocol
        }
      ]

      # Environment Variables
      environment = [
        for env in container.environment : {
          name  = env.name
          value = env.value
        }
      ]

      # Secrets (Security Control ECS-04: Secrets Management)
      secrets = [
        for secret in container.secrets : {
          name      = secret.name
          valueFrom = secret.value_from
        }
      ]

      # Logging Configuration (Security Control ECS-02: Logging)
      logConfiguration = container.log_configuration != null ? {
        logDriver = container.log_configuration.log_driver
        options   = container.log_configuration.options
      } : null

      # Health Check
      healthCheck = container.health_check != null ? {
        command     = container.health_check.command
        interval    = container.health_check.interval
        timeout     = container.health_check.timeout
        retries     = container.health_check.retries
        startPeriod = container.health_check.start_period
      } : null

      # Security Options (Security Control ECS-01: Container Security)
      readonlyRootFilesystem = container.readonly_root_filesystem
      privileged            = container.privileged
      user                  = container.user

      # Linux Parameters
      linuxParameters = container.linux_parameters != null ? {
        capabilities = container.linux_parameters.capabilities != null ? {
          add  = container.linux_parameters.capabilities.add
          drop = container.linux_parameters.capabilities.drop
        } : null
        devices = container.linux_parameters.devices != null ? [
          for device in container.linux_parameters.devices : {
            hostPath      = device.host_path
            containerPath = device.container_path
            permissions   = device.permissions
          }
        ] : null
        initProcessEnabled = container.linux_parameters.init_process_enabled
        maxSwap           = container.linux_parameters.max_swap
        swappiness        = container.linux_parameters.swappiness
        tmpfs = container.linux_parameters.tmpfs != null ? [
          for tmpfs in container.linux_parameters.tmpfs : {
            containerPath = tmpfs.container_path
            size          = tmpfs.size
            mountOptions  = tmpfs.mount_options
          }
        ] : null
      } : null

      # Mount Points
      mountPoints = [
        for mount in container.mount_points : {
          sourceVolume  = mount.source_volume
          containerPath = mount.container_path
          readOnly      = mount.read_only
        }
      ]

      # Volumes From
      volumesFrom = [
        for volume in container.volumes_from : {
          sourceContainer = volume.source_container
          readOnly       = volume.read_only
        }
      ]
    }
  ])

  # Volume Configuration (Security Control ECS-05: Data Encryption)
  dynamic "volume" {
    for_each = var.volumes
    content {
      name      = volume.value.name
      host_path = volume.value.host_path

      dynamic "docker_volume_configuration" {
        for_each = volume.value.docker_volume_configuration != null ? [volume.value.docker_volume_configuration] : []
        content {
          scope         = docker_volume_configuration.value.scope
          autoprovision = docker_volume_configuration.value.autoprovision
          driver        = docker_volume_configuration.value.driver
          driver_opts   = docker_volume_configuration.value.driver_opts
          labels        = docker_volume_configuration.value.labels
        }
      }

      dynamic "efs_volume_configuration" {
        for_each = volume.value.efs_volume_configuration != null ? [volume.value.efs_volume_configuration] : []
        content {
          file_system_id          = efs_volume_configuration.value.file_system_id
          root_directory          = efs_volume_configuration.value.root_directory
          transit_encryption      = efs_volume_configuration.value.transit_encryption
          transit_encryption_port = efs_volume_configuration.value.transit_encryption_port

          dynamic "authorization_config" {
            for_each = efs_volume_configuration.value.authorization_config != null ? [efs_volume_configuration.value.authorization_config] : []
            content {
              access_point_id = authorization_config.value.access_point_id
              iam            = authorization_config.value.iam
            }
          }
        }
      }

      dynamic "fsx_windows_file_server_volume_configuration" {
        for_each = volume.value.fsx_windows_file_server_volume_configuration != null ? [volume.value.fsx_windows_file_server_volume_configuration] : []
        content {
          file_system_id = fsx_windows_file_server_volume_configuration.value.file_system_id
          root_directory = fsx_windows_file_server_volume_configuration.value.root_directory

          authorization_config {
            credentials_parameter = fsx_windows_file_server_volume_configuration.value.authorization_config.credentials_parameter
            domain               = fsx_windows_file_server_volume_configuration.value.authorization_config.domain
          }
        }
      }
    }
  }

  # Placement Constraints
  dynamic "placement_constraints" {
    for_each = var.placement_constraints
    content {
      type       = placement_constraints.value.type
      expression = placement_constraints.value.expression
    }
  }

  # Proxy Configuration
  dynamic "proxy_configuration" {
    for_each = var.proxy_configuration != null ? [var.proxy_configuration] : []
    content {
      type           = proxy_configuration.value.type
      container_name = proxy_configuration.value.container_name
      properties     = proxy_configuration.value.properties
    }
  }

  # Inference Accelerator
  dynamic "inference_accelerator" {
    for_each = var.inference_accelerators
    content {
      device_name = inference_accelerator.value.device_name
      device_type = inference_accelerator.value.device_type
    }
  }

  tags = local.standard_tags
}

# ECS Service
resource "aws_ecs_service" "main" {
  count = var.create_service ? 1 : 0

  name            = var.service_name
  cluster         = aws_ecs_cluster.main.id
  task_definition = var.create_task_definition ? aws_ecs_task_definition.main[0].arn : var.existing_task_definition_arn
  desired_count   = var.desired_count

  launch_type                        = var.launch_type
  platform_version                   = var.platform_version
  scheduling_strategy                = var.scheduling_strategy
  enable_execute_command             = var.enable_execute_command
  enable_ecs_managed_tags           = var.enable_ecs_managed_tags
  propagate_tags                    = var.propagate_tags
  health_check_grace_period_seconds = var.health_check_grace_period_seconds

  # Capacity Provider Strategy
  dynamic "capacity_provider_strategy" {
    for_each = var.service_capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight           = capacity_provider_strategy.value.weight
      base             = capacity_provider_strategy.value.base
    }
  }

  # Network Configuration (Security Control ECS-01: Network Security)
  dynamic "network_configuration" {
    for_each = var.network_configuration != null ? [var.network_configuration] : []
    content {
      subnets          = network_configuration.value.subnets
      security_groups  = network_configuration.value.security_groups
      assign_public_ip = network_configuration.value.assign_public_ip
    }
  }

  # Load Balancer Configuration
  dynamic "load_balancer" {
    for_each = var.load_balancers
    content {
      target_group_arn = load_balancer.value.target_group_arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }

  # Service Registries
  dynamic "service_registries" {
    for_each = var.service_registries
    content {
      registry_arn   = service_registries.value.registry_arn
      port          = service_registries.value.port
      container_name = service_registries.value.container_name
      container_port = service_registries.value.container_port
    }
  }

  # Placement Constraints
  dynamic "placement_constraints" {
    for_each = var.service_placement_constraints
    content {
      type       = placement_constraints.value.type
      expression = placement_constraints.value.expression
    }
  }

  # Placement Strategy
  dynamic "ordered_placement_strategy" {
    for_each = var.ordered_placement_strategy
    content {
      type  = ordered_placement_strategy.value.type
      field = ordered_placement_strategy.value.field
    }
  }

  # Deployment Configuration
  dynamic "deployment_configuration" {
    for_each = var.deployment_configuration != null ? [var.deployment_configuration] : []
    content {
      maximum_percent         = deployment_configuration.value.maximum_percent
      minimum_healthy_percent = deployment_configuration.value.minimum_healthy_percent

      dynamic "deployment_circuit_breaker" {
        for_each = deployment_configuration.value.deployment_circuit_breaker != null ? [deployment_configuration.value.deployment_circuit_breaker] : []
        content {
          enable   = deployment_circuit_breaker.value.enable
          rollback = deployment_circuit_breaker.value.rollback
        }
      }
    }
  }

  # Deployment Controller
  dynamic "deployment_controller" {
    for_each = var.deployment_controller != null ? [var.deployment_controller] : []
    content {
      type = deployment_controller.value.type
    }
  }

  tags = local.standard_tags

  depends_on = [aws_ecs_task_definition.main]
}

# CloudWatch Log Group for ECS (Security Control ECS-02: Logging)
resource "aws_cloudwatch_log_group" "ecs" {
  count = var.create_cloudwatch_log_group ? 1 : 0

  name              = "/ecs/${var.cluster_name}"
  retention_in_days = var.log_retention_in_days
  kms_key_id        = var.log_group_kms_key_id

  tags = merge(
    local.standard_tags,
    {
      SecurityControl = "ECS_02_Logging"
      LogType         = "ecs_cluster"
    }
  )
}

# CloudWatch Alarms for ECS Service Monitoring
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  count = var.create_service && var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.service_name}-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_utilization_threshold
  alarm_description   = "This metric monitors ECS service CPU utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    ServiceName = aws_ecs_service.main[0].name
    ClusterName = aws_ecs_cluster.main.name
  }

  tags = merge(
    local.standard_tags,
    {
      SecurityControl = "ECS_02_Monitoring"
      AlarmType       = "cpu_utilization"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
  count = var.create_service && var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.service_name}-memory-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.memory_utilization_threshold
  alarm_description   = "This metric monitors ECS service memory utilization"
  alarm_actions       = var.alarm_actions

  dimensions = {
    ServiceName = aws_ecs_service.main[0].name
    ClusterName = aws_ecs_cluster.main.name
  }

  tags = merge(
    local.standard_tags,
    {
      SecurityControl = "ECS_02_Monitoring"
      AlarmType       = "memory_utilization"
    }
  )
}

# Security Control Validation - Local values for validation
locals {
  # Security Control ECS-01: Validate container security
  container_security_validation = var.security_controls_enabled ? (
    alltrue([
      for container in var.container_definitions :
      container.readonly_root_filesystem == true && container.privileged == false
    ]) ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"

  # Security Control ECS-02: Validate logging
  logging_validation = var.enable_logging ? (
    var.create_cloudwatch_log_group ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"

  # Security Control ECS-03: Validate execute command logging
  execute_command_validation = var.enable_execute_command_logging ? (
    var.execute_command_log_group_name != null ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"

  # Security Control ECS-04: Validate secrets management
  secrets_validation = var.security_controls_enabled ? (
    alltrue([
      for container in var.container_definitions :
      length(container.secrets) > 0 ? alltrue([
        for secret in container.secrets :
        can(regex("^arn:aws:secretsmanager:", secret.value_from)) ||
        can(regex("^arn:aws:ssm:", secret.value_from))
      ]) : true
    ]) ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"

  # Security Control ECS-05: Validate encryption
  encryption_validation = var.enable_encryption ? (
    var.log_group_kms_key_id != null ? "COMPLIANT" : "NON_COMPLIANT"
  ) : "DISABLED"
}

# Security Control Validation Output
resource "null_resource" "security_controls_validation" {
  count = var.security_controls_enabled ? 1 : 0

  triggers = {
    container_security_status    = local.container_security_validation
    logging_status              = local.logging_validation
    execute_command_status      = local.execute_command_validation
    secrets_management_status   = local.secrets_validation
    encryption_status           = local.encryption_validation
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "ECS Security Controls Validation Report:"
      echo "ECS-01 Container Security: ${local.container_security_validation}"
      echo "ECS-02 Logging: ${local.logging_validation}"
      echo "ECS-03 Execute Command Logging: ${local.execute_command_validation}"
      echo "ECS-04 Secrets Management: ${local.secrets_validation}"
      echo "ECS-05 Encryption: ${local.encryption_validation}"
    EOT
  }
}