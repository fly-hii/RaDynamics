"use client";

import React, { useEffect, useState } from "react";
import { 
  Zap, 
  CheckCircle, 
  AlertTriangle, 
  Clock, 
  BarChart3, 
  ShieldCheck, 
  Globe, 
  Plus,
  ArrowUpRight,
  Loader2,
  Box,
  Rocket
} from "lucide-react";
import styles from "./page.module.css";
import axios from "axios";
import { motion } from "framer-motion";

export default function DashboardOverview() {
  const [stats, setStats] = useState<any>(null);
  const [deployments, setDeployments] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [statsResp, deployResp, appResp] = await Promise.all([
          axios.get("/api/analytics?type=overview"),
          axios.get("/api/deployments?limit=5"),
          axios.get("/api/applications")
        ]);
        setStats({
          ...statsResp.data.overview,
          totalApps: (appResp.data.applications || []).length
        });
        
        const combined = [
          ...(deployResp.data.deployments || []),
          ...(appResp.data.applications || []).map((a: any) => ({
            ...a,
            resourceName: a.name,
            resourceType: 'app',
            isApp: true
          }))
        ].sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
        .slice(0, 5);

        setDeployments(combined);
      } catch (error) {
        console.error("Failed to fetch dashboard data:", error);
      } finally {
        setLoading(false);
      }
    };
    fetchData();
  }, []);

  if (loading) {
    return (
      <div className={styles.loaderContainer}>
        <Loader2 className={styles.spinner} size={48} />
        <p>Syncing with Cloud Control Plane...</p>
      </div>
    );
  }

  const statCards = [
    { label: "Active AWS Accounts", value: stats?.activeAWSAccounts || 0, icon: Globe, color: "#3b82f6" },
    { label: "Total Applications", value: stats?.totalApps || 0, icon: Rocket, color: "#f43f5e" },
    { label: "Cloud Resources", value: stats?.totalDeployments || 0, icon: Box, color: "#8b5cf6" },
    { label: "Success Rate", value: `${stats?.successRate || 0}%`, icon: ShieldCheck, color: "#10b981" },
  ];

  return (
    <div className={styles.container}>
      {/* Stats Grid */}
      <div className={styles.statsGrid}>
        {statCards.map((stat, i) => (
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: i * 0.1 }}
            key={stat.label} 
            className={styles.statCard}
          >
            <div className={styles.statIcon} style={{ background: `${stat.color}15`, color: stat.color }}>
              <stat.icon size={24} />
            </div>
            <div className={styles.statInfo}>
              <p className={styles.statLabel}>{stat.label}</p>
              <h3 className={styles.statValue}>{stat.value}</h3>
            </div>
          </motion.div>
        ))}
      </div>

      <div className={styles.contentGrid}>
        {/* Recent Deployments */}
        <div className={styles.mainCard}>
          <div className={styles.cardHeader}>
            <h3>Recent Infrastructure Changes</h3>
            <button className={styles.viewAllBtn}>View All</button>
          </div>
          <div className={styles.deployList}>
            {deployments.length > 0 ? (
              deployments.map((d) => (
                <div key={d._id} className={styles.deployItem}>
                  <div className={styles.deployInfo}>
                    <div className={styles.resourceIcon}>
                       <Box size={20} />
                    </div>
                    <div>
                      <h4 className={styles.resourceName}>{d.resourceName}</h4>
                      <p className={styles.resourceType}>{d.resourceType.toUpperCase()} • {new Date(d.createdAt).toLocaleDateString()}</p>
                    </div>
                  </div>
                  <div className={`${styles.statusBadge} ${styles[d.status]}`}>
                    {d.status === 'completed' && <CheckCircle size={14} />}
                    {d.status === 'failed' && <AlertTriangle size={14} />}
                    {d.status === 'pending' && <Clock size={14} />}
                    {d.status.charAt(0).toUpperCase() + d.status.slice(1)}
                  </div>
                </div>
              ))
            ) : (
              <div className={styles.emptyState}>
                <Plus size={48} className={styles.emptyIcon} />
                <p>No deployments found. Start by provisioning your first resource.</p>
                <button className={styles.createBtn}>Create Deployment</button>
              </div>
            )}
          </div>
        </div>

        {/* Action Panel */}
        <div className={styles.sidePanel}>
           <div className={styles.actionCard}>
              <h4>Quick Actions</h4>
              <div className={styles.actionGrid}>
                 <div className={styles.actionItem}>
                    <Zap size={18} />
                    <span>Deploy EC2</span>
                 </div>
                 <div className={styles.actionItem}>
                    <Box size={18} />
                    <span>Create S3</span>
                 </div>
                 <div className={styles.actionItem}>
                    <Globe size={18} />
                    <span>New VPC</span>
                 </div>
              </div>
           </div>

           <div className={styles.healthCard}>
              <div className={styles.healthHeader}>
                 <h4>Global Health</h4>
                 <div className={styles.pulse} />
              </div>
              <div className={styles.metricRow}>
                 <span>API Latency</span>
                 <span className={styles.metricValue}>24ms</span>
              </div>
              <div className={styles.metricRow}>
                 <span>Auth Token Status</span>
                 <span className={styles.metricValue} style={{color: '#10b981'}}>Active</span>
              </div>
           </div>
        </div>
      </div>
    </div>
  );
}
