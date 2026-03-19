"use client";

import React, { useEffect, useState } from "react";
import { 
  Zap, 
  CheckCircle, 
  AlertTriangle, 
  Clock, 
  Box, 
  Search,
  Filter,
  ExternalLink,
  ChevronDown,
  Terminal,
  RefreshCw,
  Loader2
} from "lucide-react";
import styles from "./page.module.css";
import axios from "axios";
import { motion, AnimatePresence } from "framer-motion";

export default function DeploymentsMonitor() {
  const [deployments, setDeployments] = useState<any[]>([]);
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  const fetchDeployments = async () => {
    setRefreshing(true);
    try {
      const resp = await axios.get("/api/deployments?limit=20");
      setDeployments(resp.data.deployments);
    } catch (err) {
      console.error("Failed to fetch deployments:", err);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchDeployments();
    const interval = setInterval(fetchDeployments, 15000); // Polling every 15s
    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return (
      <div className={styles.loaderContainer}>
        <Loader2 className={styles.spinner} size={48} />
        <p>Fetching infrastructure state...</p>
      </div>
    );
  }

  return (
    <div className={styles.container}>
      <header className={styles.header}>
        <div className={styles.titleInfo}>
           <h1>Infrastructure Monitor</h1>
           <p>Real-time view of your automated provisioning and state changes.</p>
        </div>
        <button className={styles.refreshBtn} onClick={fetchDeployments} disabled={refreshing}>
           <RefreshCw size={18} className={refreshing ? styles.spin : ""} />
           Sync State
        </button>
      </header>

      <div className={styles.controlBar}>
         <div className={styles.search}>
            <Search size={18} className={styles.searchIcon} />
            <input type="text" placeholder="Filter by resource name or ID..." />
         </div>
         <div className={styles.filters}>
            <button className={styles.filterBtn}><Filter size={18} /> Resource Type</button>
            <button className={styles.filterBtn}><Filter size={18} /> Status</button>
         </div>
      </div>

      <div className={styles.tableCard}>
         <div className={styles.tableHeader}>
            <div className={styles.col}>Resource</div>
            <div className={styles.col}>Provider</div>
            <div className={styles.col}>Status</div>
            <div className={styles.col}>Date</div>
            <div className={styles.col}>Actions</div>
         </div>
         <div className={styles.tableBody}>
            {deployments.map((d) => (
               <div key={d._id} className={styles.rowWrapper}>
                  <div className={styles.row} onClick={() => setExpandedId(expandedId === d._id ? null : d._id)}>
                     <div className={styles.col}>
                        <div className={styles.resourceBrief}>
                           <div className={styles.resourceIcon}><Box size={18} /></div>
                           <div>
                              <span className={styles.resName}>{d.resourceName}</span>
                              <span className={styles.resType}>{d.resourceType.toUpperCase()}</span>
                           </div>
                        </div>
                     </div>
                     <div className={styles.col}>
                        <span className={styles.providerTag}>AWS</span>
                     </div>
                     <div className={styles.col}>
                        <div className={`${styles.statusBadge} ${styles[d.status]}`}>
                           {d.status === 'completed' && <CheckCircle size={14} />}
                           {d.status === 'failed' && <AlertTriangle size={14} />}
                           {d.status === 'pending' && <Clock size={14} />}
                           {d.status}
                        </div>
                     </div>
                     <div className={styles.col}>
                        <span className={styles.dateText}>{new Date(d.createdAt).toLocaleString()}</span>
                     </div>
                     <div className={styles.col}>
                        <button className={styles.actionBtn}>
                           <ChevronDown size={18} />
                        </button>
                     </div>
                  </div>

                  <AnimatePresence>
                     {expandedId === d._id && (
                        <motion.div 
                           initial={{ height: 0, opacity: 0 }}
                           animate={{ height: "auto", opacity: 1 }}
                           exit={{ height: 0, opacity: 0 }}
                           className={styles.expandedArea}
                        >
                           <div className={styles.tabs}>
                              <button className={styles.tabActive}>Execution Logs</button>
                              <button className={styles.tab}>Configuration</button>
                              <button className={styles.tab}>Cloud State</button>
                           </div>
                           <div className={styles.terminal}>
                              <div className={styles.terminalHeader}>
                                 <Terminal size={14} /> Output Log (Terraform)
                              </div>
                              <pre className={styles.logBody}>
                                 {d.terraformOutput || d.errorLog || "No logs available for this deployment."}
                              </pre>
                           </div>
                        </motion.div>
                     )}
                  </AnimatePresence>
               </div>
            ))}
         </div>
      </div>
    </div>
  );
}
