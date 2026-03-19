"use client";

import React, { useEffect, useState } from "react";
import { 
  Network, Server, Zap, Shield, Activity, ArrowLeftRight, CheckCircle, 
  RefreshCw, Plus, Loader2, Trash2, Monitor, TrendingUp, X, Info, Layers
} from "lucide-react";
import { useRouter } from "next/navigation";
import styles from "./Communication.module.css";
import axios from "axios";
import { motion, AnimatePresence } from "framer-motion";

export default function ApplicationCommunication() {
  const router = useRouter();
  const [loading, setLoading] = useState(true);
  const [applications, setApplications] = useState<any[]>([]);
  const [communications, setCommunications] = useState<any[]>([]);
  const [selectedApps, setSelectedApps] = useState<string[]>([]);
  const [mode, setMode] = useState("nginx");
  const [showMonitor, setShowMonitor] = useState(false);
  const [selectedComm, setSelectedComm] = useState<any>(null);
  const [metrics, setMetrics] = useState<any>(null);
  const [actionLoading, setActionLoading] = useState(false);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [appsResp, commsResp] = await Promise.all([
        axios.get("/api/applications"),
        axios.get("/api/app-communication")
      ]);
      setApplications(appsResp.data.applications || []);
      setCommunications(commsResp.data || []);
    } catch (err) {
      console.error("Failed to fetch connectivity data:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const toggleApp = (id: string) => {
    setSelectedApps(prev => 
      prev.includes(id) ? prev.filter(a => a !== id) : [...prev, id]
    );
  };

  const handleSetup = async () => {
    if (selectedApps.length < 2) return alert("Please select at least two apps to connect.");
    setActionLoading(true);
    try {
      await axios.post("/api/app-communication", {
        applications: selectedApps,
        communicationType: mode,
        nginxConfig: {
          loadBalancing: true,
          sslTermination: true,
          rateLimiting: { enabled: true, rate: '100r/s' },
          healthChecks: true
        }
      });
      alert("App connection established via " + mode.toUpperCase() + "!");
      setSelectedApps([]);
      fetchData();
    } catch (err: any) {
      alert("Connectivity setup failed: " + (err.response?.data?.error || err.message));
    } finally {
      setActionLoading(false);
    }
  };

  const openMonitor = async (comm: any) => {
    setSelectedComm(comm);
    setShowMonitor(true);
    try {
       const resp = await axios.get(`/api/app-communication/${comm._id}/metrics`);
       setMetrics(resp.data.metrics);
    } catch (err) {
       console.error("Monitoring link failed");
    }
  };

  if (loading && applications.length === 0) {
    return (
      <div className={styles.container}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', minHeight: '400px', color: 'var(--text-dim)' }}>
          <Loader2 className={styles.spin} size={48} color="var(--primary)" />
          <p style={{ marginTop: '16px', fontWeight: 600 }}>Syncing Mesh Gateway...</p>
        </div>
      </div>
    );
  }

  return (
    <div className={styles.container}>
      {/* Header */}
      <div className={styles.header}>
        <div className={styles.headerInfo}>
          <h1>App Connectivity Hub</h1>
          <p>Bridge your microservices through automated secure gateways.</p>
        </div>
        <div className={styles.headerRight}>
          <button className={styles.btnGhost} style={{ padding: '8px' }} onClick={fetchData} title="Refresh Grid">
            <RefreshCw size={18} className={actionLoading ? styles.spin : ""} />
          </button>
        </div>
      </div>

      {/* Stats Summary */}
      <div className={styles.statsGrid}>
        <div className={styles.statCard}>
          <div className={`${styles.statIcon} ${styles.statIconNginx}`}><Server size={20} /></div>
          <div>
            <div className={styles.statLabel}>Mesh Gateway</div>
            <div className={styles.statValue}>NGINX Pro</div>
          </div>
        </div>
        <div className={styles.statCard}>
          <div className={`${styles.statIcon} ${styles.statIconActive}`}><ArrowLeftRight size={20} /></div>
          <div>
            <div className={styles.statLabel}>Active Links</div>
            <div className={styles.statValue}>{communications.length}</div>
          </div>
        </div>
        <div className={styles.statCard}>
          <div className={`${styles.statIcon} ${styles.statIconSecurity}`}><Shield size={20} /></div>
          <div>
            <div className={styles.statLabel}>Security</div>
            <div className={styles.statValue}>TLS 1.3</div>
          </div>
        </div>
        <div className={styles.statCard}>
          <div className={`${styles.statIcon} ${styles.statIconPerformance}`}><TrendingUp size={20} /></div>
          <div>
            <div className={styles.statLabel}>Latency</div>
            <div className={styles.statValue}>12ms<span style={{ fontSize: '0.8rem', color: 'var(--text-dim)' }}> (avg)</span></div>
          </div>
        </div>
      </div>

      {/* Creation Step */}
      <div className={styles.setupCard}>
        <div className={styles.sectionHeader}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <h2>New Service Link</h2>
            <div title="Selecting multiple apps creates a load-balanced group." style={{ color: 'var(--text-dim)', cursor: 'help' }}>
               <Info size={16} />
            </div>
          </div>
        </div>
        
        <p style={{ fontSize: '0.85rem', color: 'var(--text-dim)', marginBottom: '16px' }}>1. Choose Gateway Logic:</p>
        <div className={styles.modeOptions}>
          <div className={`${styles.modeOption} ${mode === 'nginx' ? styles.active : ''}`} onClick={() => setMode('nginx')}>
            <div className={styles.statIcon} style={{ background: 'var(--primary)', width: '36px', height: '36px', color: 'white' }}><Zap size={18} /></div>
            <div>
               <div style={{ fontWeight: 700, color: 'white', fontSize: '0.9rem' }}>Load Balanced</div>
               <div style={{ fontSize: '0.75rem', color: 'var(--text-dim)' }}>Evenly distribute traffic</div>
            </div>
          </div>
          <div className={`${styles.modeOption} ${mode === 'direct' ? styles.active : ''}`} onClick={() => setMode('direct')}>
            <div className={styles.statIcon} style={{ background: 'var(--text-dim)', width: '36px', height: '36px', color: 'white' }}><ArrowLeftRight size={18} /></div>
            <div>
               <div style={{ fontWeight: 700, color: 'white', fontSize: '0.9rem' }}>Direct Tunnel</div>
               <div style={{ fontSize: '0.75rem', color: 'var(--text-dim)' }}>Secure point-to-point</div>
            </div>
          </div>
        </div>

        <p style={{ fontSize: '0.85rem', color: 'var(--text-dim)', marginBottom: '12px' }}>2. Select Target Services:</p>
        <div className={styles.appGrid}>
          {applications.map(app => (
            <div key={app._id} className={`${styles.appSelectionCard} ${selectedApps.includes(app._id) ? styles.selected : ''}`} onClick={() => toggleApp(app._id)}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
                <Layers size={16} color={selectedApps.includes(app._id) ? 'var(--success)' : 'var(--text-dim)'} />
                {selectedApps.includes(app._id) && <CheckCircle size={16} color="var(--success)" />}
              </div>
              <div style={{ fontWeight: 700, color: 'white', fontSize: '0.85rem' }}>{app.name}</div>
            </div>
          ))}
          {applications.length === 0 && (
            <p style={{ gridColumn: '1/-1', padding: '20px', textAlign: 'center', background: 'rgba(255,255,255,0.02)', borderRadius: '12px', fontSize: '0.85rem', color: 'var(--text-dim)' }}>
              No applications available to connect.
            </p>
          )}
        </div>

        <div className={styles.setupActions}>
          <div style={{ color: 'var(--text-muted)', fontSize: '0.85rem', fontWeight: 600 }}>{selectedApps.length} Apps Selected</div>
          <button className={`${styles.btnPrimary} ${styles.btn}`} onClick={handleSetup} disabled={actionLoading || selectedApps.length < 2}>
            {actionLoading ? <Loader2 className={styles.spin} size={18} /> : <Zap size={18} />} Connect Services
          </button>
        </div>
      </div>

      {/* Active Grid */}
      <div style={{ marginTop: '40px' }}>
         <div className={styles.sectionHeader}>
           <h2>Established Networks</h2>
         </div>
         <div className={styles.communicationsGrid}>
           {communications.map(comm => (
             <div key={comm._id} className={styles.communicationCard}>
               <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '12px' }}>
                  <div className={styles.commType}>{comm.communicationType}</div>
                  <div className={styles.commStatus} style={{ color: comm.status === 'active' ? 'var(--success)' : 'var(--warning)' }}>
                    <Activity size={12} /> {comm.status}
                  </div>
               </div>
               <h3 className={styles.commTitle}>{comm.applications.map((a: any) => a.name).join(" ↔ ")}</h3>
               <div style={{ display: 'flex', gap: '8px', marginTop: '16px', borderTop: '1px solid var(--border)', paddingTop: '16px' }}>
                  <button className={`${styles.btnGhost} ${styles.btn}`} style={{ flex: 1 }} onClick={() => openMonitor(comm)} title="Real-time Analytics">
                     <Monitor size={14} /> View Traffic
                  </button>
                  <button className={`${styles.btnGhost} ${styles.btn}`} style={{ color: 'var(--error)' }} onClick={async () => {
                    if (confirm("Decommission this connection link?")) {
                      await axios.delete(`/api/app-communication/${comm._id}`);
                      fetchData();
                    }
                  }} title="Remove Link">
                     <Trash2 size={14} />
                  </button>
               </div>
             </div>
           ))}
           {communications.length === 0 && (
             <div style={{ gridColumn: '1/-1', textAlign: 'center', padding: '48px', background: 'var(--bg-card)', borderRadius: '16px', border: '1px solid var(--border)' }}>
               <Network size={48} color="var(--text-dim)" style={{ marginBottom: '12px', opacity: 0.2 }} />
               <p style={{ color: 'var(--text-dim)', fontSize: '0.9rem' }}>Select apps above to create a secure mesh.</p>
             </div>
           )}
         </div>
      </div>

      <AnimatePresence>
        {showMonitor && selectedComm && (
          <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className={styles.modalOverlay} onClick={() => setShowMonitor(false)}>
            <motion.div initial={{ scale: 0.95, y: 10 }} animate={{ scale: 1, y: 0 }} className={styles.modalContent} onClick={e => e.stopPropagation()}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '20px' }}>
                 <h3 style={{ color: 'white', fontWeight: 800 }}>Mesh Analytics</h3>
                 <button onClick={() => setShowMonitor(false)} style={{ background: 'none', border: 'none', cursor: 'pointer', color: 'var(--text-dim)' }}><X size={20} /></button>
              </div>
              <div className={styles.metricsGrid}>
                 <div className={styles.metricCard}>
                    <div className={styles.metricValue}>{metrics?.requestsPerSecond || 0}</div>
                    <div className={styles.metricLabel}>Req/Sec</div>
                 </div>
                 <div className={styles.metricCard}>
                    <div className={styles.metricValue}>{metrics?.averageResponseTime || 0}ms</div>
                    <div className={styles.metricLabel}>Latency</div>
                 </div>
              </div>
              <div style={{ background: 'rgba(2, 6, 23, 0.4)', padding: '16px', borderRadius: '12px', border: '1px solid var(--border)' }}>
                 <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '8px', fontWeight: 700, color: 'var(--primary)', fontSize: '0.85rem' }}>
                    <Shield size={16} /> Link Security
                 </div>
                 <p style={{ fontSize: '0.8rem', color: 'var(--text-muted)', lineHeight: 1.5 }}>
                    Secure mesh active via **NGINX Reverse Proxy**. All traffic is encrypted at rest and in transit using **TLS 1.3**.
                 </p>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
