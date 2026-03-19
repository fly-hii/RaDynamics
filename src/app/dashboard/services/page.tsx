"use client";

import React from "react";
import { motion } from "framer-motion";
import {
  Server, Box, Database, Network, Zap, Shield, Globe, Layers,
  Activity, Lock, HardDrive, Cpu, ArrowRight, Plus, CheckCircle
} from "lucide-react";
import { useRouter } from "next/navigation";
import styles from "./page.module.css";

const services = [
  {
    id: "ec2", name: "EC2 Instances", category: "Compute", icon: Server, color: "#3b82f6",
    desc: "Launch and manage virtual machines with full control over instance type, AMI, security groups, and networking.",
    features: ["Auto-scaling", "IMDSv2 enforced", "Multi-AZ HA"],
    path: "/dashboard/services/deploy/ec2",
  },
  {
    id: "s3", name: "S3 Buckets", category: "Storage", icon: Box, color: "#10b981",
    desc: "Create secure, scalable object storage with versioning, encryption, and lifecycle policies.",
    features: ["AES-256 encryption", "Versioning", "Lifecycle rules"],
    path: "/dashboard/services/deploy/s3",
  },
  {
    id: "rds", name: "RDS Databases", category: "Database", icon: Database, color: "#f59e0b",
    desc: "Provision managed relational databases with automated backups, multi-AZ replication, and read replicas.",
    features: ["MySQL/Postgres/Aurora", "Auto-backup", "Multi-AZ"],
    path: "/dashboard/services/deploy/rds",
  },
  {
    id: "vpc", name: "VPC Networks", category: "Networking", icon: Network, color: "#8b5cf6",
    desc: "Create isolated virtual networks with custom subnets, route tables, NAT gateways and peering.",
    features: ["Public/private subnets", "NAT gateway", "Flow logs"],
    path: "/dashboard/services/deploy/vpc",
  },
  {
    id: "lambda", name: "Lambda Functions", category: "Serverless", icon: Zap, color: "#6366f1",
    desc: "Deploy event-driven serverless functions with automatic scaling and sub-millisecond cold start.",
    features: ["Any runtime", "Event triggers", "VPC support"],
    path: "/dashboard/services/deploy/lambda",
  },
  {
    id: "iam", name: "IAM Policies", category: "Security", icon: Lock, color: "#ef4444",
    desc: "Create users, roles, and policies with least-privilege access and automated key rotation.",
    features: ["MFA enforcement", "Role policies", "Key rotation"],
    path: "/dashboard/services/deploy/iam",
  },
  {
    id: "eks", name: "EKS Clusters", category: "Containers", icon: Layers, color: "#ec4899",
    desc: "Launch managed Kubernetes clusters with node groups, Fargate profiles, and add-ons.",
    features: ["Managed node groups", "Fargate", "Cluster add-ons"],
    path: "/dashboard/services/deploy/eks",
  },
  {
    id: "cloudfront", name: "CloudFront CDN", category: "Edge", icon: Globe, color: "#14b8a6",
    desc: "Distribute content globally with SSL termination, caching policies, and DDoS protection.",
    features: ["SSL/TLS", "WAF integration", "Custom origins"],
    path: "/dashboard/services/deploy/cloudfront",
  },
  {
    id: "app", name: "App Deployment", category: "Application", icon: Zap, color: "#f43f5e",
    desc: "Deploy web applications directly from GitHub or Docker images to ECS Fargate or EC2 with automated CI/CD.",
    features: ["GitHub Integration", "Docker support", "ECS Fargate"],
    path: "/dashboard/services/deploy/app",
  },
  {
    id: "cloudwatch", name: "CloudWatch", category: "Monitoring", icon: Activity, color: "#94a3b8",
    desc: "Set up dashboards, alarms, and log groups for full observability across your AWS environment.",
    features: ["Custom metrics", "Alarms", "Log insights"],
    path: "/dashboard/services/deploy/cloudwatch",
  },
  {
    id: "communication", name: "App Communication", category: "Application", icon: Network, color: "#3b82f6",
    desc: "Establish secure, load-balanced communication between multiple microservices with NGINX reverse proxy logic.",
    features: ["Load balancing", "Service discovery", "Metrics"],
    path: "/dashboard/services/communication",
  },
];

const categoryColors: Record<string, string> = {
  Compute: "#3b82f6", Storage: "#10b981", Database: "#f59e0b",
  Networking: "#8b5cf6", Serverless: "#6366f1", Security: "#ef4444",
  Containers: "#ec4899", Edge: "#14b8a6", Monitoring: "#94a3b8",
};

export default function ServicesPage() {
  const router = useRouter();

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <div>
          <h1>Cloud Services</h1>
          <p>Provision, configure, and deploy AWS infrastructure with one click.</p>
        </div>
        <button className={styles.accountsBtn} onClick={() => router.push('/dashboard/accounts')}>
          <Plus size={18} /> Connect AWS Account
        </button>
      </div>

      <div className={styles.grid}>
        {services.map((svc, i) => (
          <motion.div
            key={svc.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.06 }}
            className={styles.card}
            onClick={() => router.push(svc.path)}
          >
            <div className={styles.cardTop}>
              <div className={styles.iconWrap} style={{ background: `${svc.color}15`, color: svc.color }}>
                <svc.icon size={26} />
              </div>
              <span className={styles.category} style={{ color: svc.color, background: `${svc.color}10` }}>
                {svc.category}
              </span>
            </div>

            <h3>{svc.name}</h3>
            <p>{svc.desc}</p>

            <div className={styles.features}>
              {svc.features.map((f) => (
                <span key={f} className={styles.feature}>
                  <CheckCircle size={12} /> {f}
                </span>
              ))}
            </div>

            <button className={styles.deployBtn} style={{ '--accent': svc.color } as any}>
              Deploy Now <ArrowRight size={16} />
            </button>
          </motion.div>
        ))}
      </div>
    </div>
  );
}
