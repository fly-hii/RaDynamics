#!/bin/bash
# Basic Linux User Data Template
# This template provides basic system configuration and monitoring setup

# Update system packages
yum update -y

# Install essential packages
yum install -y \
    wget \
    curl \
    unzip \
    git \
    htop \
    vim \
    amazon-cloudwatch-agent \
    awscli

# Configure environment variables
export ENVIRONMENT="${environment}"
export REGION="${aws_region}"
export INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
export RESOURCE_NAME="${resource_name}"

# Create application directories
mkdir -p /opt/applications
mkdir -p /var/log/applications

# Configure system settings
echo "net.ipv4.tcp_keepalive_time = 120" >> /etc/sysctl.conf
echo "net.ipv4.tcp_keepalive_intvl = 30" >> /etc/sysctl.conf
echo "net.ipv4.tcp_keepalive_probes = 3" >> /etc/sysctl.conf
sysctl -p

# Configure CloudWatch agent for basic monitoring
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
                        "file_path": "/var/log/messages",
                        "log_group_name": "/aws/ec2/${resource_name}/system",
                        "log_stream_name": "{instance_id}",
                        "timezone": "UTC"
                    },
                    {
                        "file_path": "/var/log/secure",
                        "log_group_name": "/aws/ec2/${resource_name}/security",
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
                "metrics_collection_interval": 60
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
            "mem": {
                "measurement": [
                    "mem_used_percent"
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
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json \
    -s
%{ endif ~}

# Create system information script
cat > /opt/applications/system-info.sh << 'EOF'
#!/bin/bash
echo "=== System Information ==="
echo "Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
echo "Instance Type: $(curl -s http://169.254.169.254/latest/meta-data/instance-type)"
echo "Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)"
echo "Private IP: $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
echo "Public IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo 'N/A')"
echo "Environment: ${environment}"
echo "Resource Name: ${resource_name}"
echo "Deployment Time: $(date)"
echo "=========================="
EOF

chmod +x /opt/applications/system-info.sh

# Run system info script and log output
/opt/applications/system-info.sh >> /var/log/applications/deployment.log

# Configure log rotation
cat > /etc/logrotate.d/applications << EOF
/var/log/applications/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 root root
}
EOF

# Set up basic health monitoring
cat > /opt/applications/health-check.sh << 'EOF'
#!/bin/bash
# Basic health check script

HEALTH_LOG="/var/log/applications/health.log"
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Check system load
LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1 | sed 's/^[ \t]*//')
LOAD_INT=$(echo "$LOAD" | cut -d. -f1)

# Check disk usage
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

# Check memory usage
MEM_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')

# Log health status
echo "$TIMESTAMP - Load: $LOAD, Disk: $DISK_USAGE%, Memory: $MEM_USAGE%" >> $HEALTH_LOG

# Alert if thresholds exceeded
if [ "$LOAD_INT" -gt 5 ] || [ "$DISK_USAGE" -gt 85 ] || [ "$MEM_USAGE" -gt 90 ]; then
    echo "$TIMESTAMP - WARNING: High resource usage detected" >> $HEALTH_LOG
fi
EOF

chmod +x /opt/applications/health-check.sh

# Set up cron job for health monitoring
cat > /etc/cron.d/system-health << EOF
# System health check every 10 minutes
*/10 * * * * root /opt/applications/health-check.sh
EOF

# Create completion marker
echo "$(date): Basic Linux user data script completed successfully" >> /var/log/applications/deployment.log
touch /opt/applications/.deployment-complete