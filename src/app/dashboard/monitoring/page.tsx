"use client";

import React, { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { Activity, CheckCircle, AlertTriangle, Clock, Cpu, HardDrive, Globe, Zap, RefreshCw, Circle } from "lucide-react";
import styles from "./page.module.css";
import axios from "axios";
import { useAuth } from "@/contexts/AuthContext";

const SERVICES_STATUS = [
  { name: "EC2 Control Plane", status: "operational", latency: "12ms" },
  { name: "S3 API", status: "operational", latency: "8ms" },
  { name: "RDS Cluster", status: "operational", latency: "24ms" },
  { name: "VPC Fabric", status: "operational", latency: "5ms" },
  { name: "Lambda Runtime", status: "operational", latency: "18ms" },
  { name: "IAM Auth", status: "operational", latency: "9ms" },
  { name: "CloudFront CDN", status: "operational", latency: "2ms" },
  { name: "CloudWatch Logs", status: "degraded", latency: "145ms" },
];

function MiniChart({ color }: { color: string }) {
  const points = Array.from({ length: 20 }, () => 30 + Math.random() * 50);
  const max = Math.max(...points);
  const min = Math.min(...points);
  const normalize = (v: number) => 60 - ((v - min) / (max - min + 1)) * 50;
  const d = points.map((p, i) => `${i === 0 ? 'M' : 'L'} ${i * 10} ${normalize(p)}`).join(' ');

  return (
    <svg width="100%" height="64" viewBox="0 200 60" preserveAspectRatio="none">
      <path d={d} fill="none" stroke={color} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
    </svg>
  );
}

export default function MonitoringPage() {
  const { token } = useAuth();
  const [stats, setStats] = useState<any>(null);
  const [deployments, setDeployments] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [lastRefresh, setLastRefresh] = useState(new Date());

  const fetchData = async () => {
    try {
      const [statsResp, deployResp] = await Promise.all([
        axios.get("/api/analytics?type=overview", { headers: { Authorization: `Bearer ${token}` } }),
        axios.get("/api/deployments?limit=8", { headers: { Authorization: `Bearer ${token}` } }),
      ]);
      setStats(statsResp.data.overview);
      setDeployments(deployResp.data.deployments || []);
    } catch {}
    setLoading(false);
    setLastRefresh(new Date());
  };

  useEffect(() => { if (token) fetchData(); }, [token]);
  useEffect(() => {
    const interval = setInterval(() => { if (token) fetchData(); }, 30000);
    return () => clearInterval(interval);
  }, [token]);

  const metrics = [
    { label: "Total Deployments", value: stats?.totalDeployments ?? "–", icon: Zap, color: "#6366f1", trend: "+12%" },
    { label: "Success Rate", value: stats?.successRate ? `${stats.successRate}%` : "–", icon: CheckCircle, color: "#10b981", trend: "+0.3%" },
    { label: "Active Accounts", value: stats?.activeAWSAccounts ?? "–", icon: Globe, color: "#3b82f6", trend: "stable" },
    { label: "Today's Changes", value: stats?.todayDeployments ?? "–", icon: Activity, color: "#f59e0b", trend: "+5" },
  ];

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <div>
          <h1>Infrastructure Monitoring</h1>
          <p>Real-time visibility across your entire cloud environment.</p>
        </div>
        <div className={styles.refreshRow}>
          <span className={styles.refreshTime}>Updated {lastRefresh.toLocaleTimeString()}</span>
          <button className={styles.refreshBtn} onClick={fetchData}><RefreshCw size={16} /> Refresh</button>
        </div>
      </div>

      {/* Metric Cards */}
      <div className={styles.metricsGrid}>
        {metrics.map((m, i) => (
          <motion.div key={m.label} initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.07 }} className={styles.metricCard}>
            <div className={styles.metricTop}>
              <div className={styles.metricIcon} style={{ background: `${m.color}15`, color: m.color }}><m.icon size={20} /></div>
              <span className={styles.trend}>{m.trend}</span>
            </div>
            <div className={styles.metricVal}>{m.value}</div>
            <div className={styles.metricLabel}>{m.label}</div>
            <div className={styles.sparkline}><MiniChart color={m.color} /></div>
          </motion.div>
        ))}
      </div>

      <div className={styles.twoCol}>
        {/* Service Health */}
        <div className={styles.panel}>
          <div className={styles.panelHeader}><h3>Service Health</h3><span className={styles.allOk}><Circle size={10} fill="#10b981" stroke="none" /> All Systems</span></div>
          <div className={styles.serviceList}>
            {SERVICES_STATUS.map((svc, i) => (
              <motion.div key={svc.name} initial={{ opacity: 0, x: -10 }} animate={{ opacity: 1, x: 0 }} transition={{ delay: i * 0.05 }} className={styles.svcRow}>
                <div className={`${styles.svcDot} ${svc.status === 'operational' ? styles.green : styles.yellow}`} />
                <span className={styles.svcName}>{svc.name}</span>
                <span className={styles.svcStatus}>{svc.status}</span>
                <span className={styles.svcLatency}>{svc.latency}</span>
              </motion.div>
            ))}
          </div>
        </div>

        {/* Recent Activity */}
        <div className={styles.panel}>
          <div className={styles.panelHeader}><h3>Recent Activity</h3></div>
          <div className={styles.activityList}>
            {deployments.length === 0 ? (
              <p className={styles.empty}>No recent deployments found.</p>
            ) : deployments.map((d: any) => (
              <div key={d._id} className={styles.actRow}>
                <div className={`${styles.actDot} ${d.status === 'completed' ? styles.green : d.status === 'failed' ? styles.red : styles.yellow}`} />
                <div className={styles.actInfo}>
                  <span className={styles.actName}>{d.resourceName}</span>
                  <span className={styles.actType}>{d.resourceType?.toUpperCase()} • {new Date(d.createdAt).toLocaleString()}</span>
                </div>
                <span className={`${styles.badge} ${styles[d.status]}`}>{d.status}</span>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
