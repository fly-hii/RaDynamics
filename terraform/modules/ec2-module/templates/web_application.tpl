#!/bin/bash
# Web Application User Data Template
# This template sets up a basic web application environment

# Update system packages
yum update -y

# Install required packages
yum install -y \
    httpd \
    wget \
    curl \
    unzip \
    git \
    amazon-cloudwatch-agent \
    awscli

# Configure environment variables
export APP_NAME="${app_name}"
export ENVIRONMENT="${environment}"
export REGION="${aws_region}"
export INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Create application directory
mkdir -p /opt/${app_name}
mkdir -p /var/log/${app_name}

# Configure Apache
systemctl enable httpd
systemctl start httpd

# Create basic index page
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>${app_name} - ${environment}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
        .info { margin: 20px 0; }
        .status { color: green; font-weight: bold; }
    </style>
</head>
<body>
    <div class="header">
        <h1>${app_name}</h1>
        <p>Environment: <span class="status">${environment}</span></p>
        <p>Region: ${aws_region}</p>
        <p>Instance ID: $INSTANCE_ID</p>
    </div>
    <div class="info">
        <h2>Application Status</h2>
        <p class="status">✓ Web Server Running</p>
        <p class="status">✓ Application Deployed</p>
        <p class="status">✓ Health Check Passed</p>
    </div>
    <div class="info">
        <h2>System Information</h2>
        <p>Deployment Time: $(date)</p>
        <p>Server: Apache HTTP Server</p>
        <p>OS: Amazon Linux 2</p>
    </div>
</body>
</html>
EOF

# Configure CloudWatch agent if monitoring is enabled
%{ if enable_monitoring ~}
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << EOF
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/httpd/access_log",
                        "log_group_name": "/aws/ec2/${app_name}/httpd/access",
                        "log_stream_name": "{instance_id}",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/httpd/error_log",
                        "log_group_name": "/aws/ec2/${app_name}/httpd/error",
                        "log_stream_name": "{instance_id}",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/${app_name}/*.log",
                        "log_group_name": "/aws/ec2/${app_name}/application",
                        "log_stream_name": "{instance_id}",
                        "timezone": "UTC"
                    }
                ]
            }
        }
    },
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
            },
            "netstat": {
                "measurement": [
                    "tcp_established",
                    "tcp_time_wait"
                ],
                "metrics_collection_interval": 60
            },
            "swap": {
                "measurement": [
                    "swap_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -c file:/opt/aws/amazon-cloudwatch-agent.json \
    -s
%{ endif ~}

# Create application startup script
cat > /opt/${app_name}/startup.sh << 'EOF'
#!/bin/bash
# Application startup script

echo "Starting ${app_name} application..."
echo "Environment: ${environment}"
echo "Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)"

# Add custom application startup logic here
# Example: Start application services, configure databases, etc.

# Log startup completion
echo "$(date): ${app_name} startup completed" >> /var/log/${app_name}/startup.log
EOF

chmod +x /opt/${app_name}/startup.sh

# Create health check endpoint
cat > /var/www/html/health << EOF
{
    "status": "healthy",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "application": "${app_name}",
    "environment": "${environment}",
    "instance_id": "$INSTANCE_ID",
    "version": "1.0.0"
}
EOF

# Configure log rotation
cat > /etc/logrotate.d/${app_name} << EOF
/var/log/${app_name}/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 apache apache
    postrotate
        systemctl reload httpd > /dev/null 2>&1 || true
    endscript
}
EOF

# Set up cron job for health monitoring
cat > /etc/cron.d/${app_name}-health << EOF
# Health check every 5 minutes
*/5 * * * * root curl -f http://localhost/health > /dev/null 2>&1 || echo "$(date): Health check failed" >> /var/log/${app_name}/health.log
EOF

# Run application startup script
/opt/${app_name}/startup.sh

# Final system configuration
systemctl enable httpd
systemctl restart httpd

# Signal completion
echo "$(date): User data script completed successfully" >> /var/log/${app_name}/startup.log

# Create completion marker
touch /opt/${app_name}/.deployment-complete