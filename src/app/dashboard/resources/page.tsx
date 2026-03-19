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
  Loader2,
  Trash2,
  Database,
  Network,
  Globe,
  Settings,
  Rocket
} from "lucide-react";
import styles from "./page.module.css";
import axios from "axios";
import { motion, AnimatePresence } from "framer-motion";
import { useRouter } from "next/navigation";
import { useAuth } from "@/contexts/AuthContext";

export default function ResourcesManager() {
  const [resources, setResources] = useState<any[]>([]);
  const [expandedId, setExpandedId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const { user } = useAuth() as any;
  const router = useRouter();

  const fetchResources = async () => {
    setRefreshing(true);
    try {
      const [depResp, appResp] = await Promise.all([
        axios.get("/api/deployments?limit=50"),
        axios.get("/api/applications")
      ]);

      const deps = (depResp.data.deployments || []).map((d: any) => ({ ...d, resType: d.resourceType, isApp: false }));
      const apps = (appResp.data.applications || []).map((a: any) => ({ 
        ...a, 
        resourceName: a.name, 
        resourceType: 'app', 
        resType: 'app',
        isApp: true,
        region: a.aws?.region || 'us-east-1'
      }));

      const combined = [...deps, ...apps].sort((a, b) => 
        new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
      );

      setResources(combined);
    } catch (err) {
      console.error("Failed to fetch resources:", err);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchResources();
    const interval = setInterval(fetchResources, 30000);
    return () => clearInterval(interval);
  }, []);

  const handleTerminate = async (resource: any, e: React.MouseEvent) => {
    e.stopPropagation();
    const confirmMsg = resource.isApp 
        ? `Are you sure you want to terminate application '${resource.name}'? This will stop and remove all associated ECS/EC2 services.`
        : "Are you sure you want to terminate this infrastructure resource? This will run 'terraform destroy'.";

    if (!confirm(confirmMsg)) return;
    
    try {
      setRefreshing(true);
      if (resource.isApp) {
          await axios.delete(`/api/applications/${resource._id}`);
      } else {
          await axios.post(`/api/deployments/${resource._id}/destroy`);
      }
      alert("Termination initiated.");
      fetchResources();
    } catch (err) {
      alert("Failed to initiate termination.");
    } finally {
      setRefreshing(false);
    }
  };

  const getResourceIcon = (type: string) => {
    switch (type.toLowerCase()) {
      case 'ec2': return <Box size={18} />;
      case 'rds': return <Database size={18} />;
      case 's3': return <Box size={18} />;
      case 'vpc': return <Network size={18} />;
      case 'lambda': return <Zap size={18} />;
      case 'app': return <Rocket size={18} />;
      default: return <Globe size={18} />;
    }
  };

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
           <h1>Cloud Resources</h1>
           <p>Active infrastructure and provisioned services.</p>
        </div>
        <div className={styles.headerActions}>
            <button className={styles.refreshBtn} onClick={fetchResources} disabled={refreshing}>
               <RefreshCw size={18} className={refreshing ? styles.spin : ""} />
               Sync
            </button>
            <button className={styles.addBtn} onClick={() => router.push("/dashboard/services")}>
               <Zap size={18} /> Deploy New
            </button>
        </div>
      </header>

      <div className={styles.controlBar}>
         <div className={styles.search}>
            <Search size={18} className={styles.searchIcon} />
            <input type="text" placeholder="Search by name, type, or region..." />
         </div>
         <div className={styles.filters}>
            <button className={styles.filterBtn}><Filter size={18} /> Type</button>
            <button className={styles.filterBtn}><Filter size={18} /> Region</button>
         </div>
      </div>

      <div className={styles.tableCard}>
         <div className={styles.tableHeader}>
            <div className={styles.col}>Resource</div>
            <div className={styles.col}>Region</div>
            <div className={styles.col}>Status</div>
            <div className={styles.col}>Age</div>
            <div className={styles.col}>Actions</div>
         </div>
         <div className={styles.tableBody}>
            {resources.length > 0 ? resources.map((r) => (
               <div key={r._id} className={styles.rowWrapper}>
                  <div className={styles.row} onClick={() => setExpandedId(expandedId === r._id ? null : r._id)}>
                     <div className={styles.col}>
                        <div className={styles.resourceBrief}>
                           <div className={styles.resourceIcon}>{getResourceIcon(r.resourceType)}</div>
                           <div>
                              <span className={styles.resName}>{r.resourceName || 'Unnamed Resource'}</span>
                              <span className={styles.resType}>{r.resourceType.toUpperCase()}</span>
                           </div>
                        </div>
                     </div>
                     <div className={styles.col}>
                        <span className={styles.regionTag}>{r.isApp ? (r.aws?.region || 'us-east-1') : (r.config?.region || 'us-east-1')}</span>
                     </div>
                     <div className={styles.col}>
                        <div className={`${styles.statusBadge} ${styles[r.status]}`}>
                           {r.status === 'completed' && <CheckCircle size={14} />}
                           {r.status === 'failed' && <AlertTriangle size={14} />}
                           {r.status === 'pending' && <Clock size={14} />}
                           {r.status === 'destroying' && <Loader2 size={14} className={styles.spin} />}
                           {r.status === 'running' && <CheckCircle size={14} />}
                           {r.status === 'deploying' && <Loader2 size={14} className={styles.spin} />}
                           {r.status}
                        </div>
                     </div>
                     <div className={styles.col}>
                        <span className={styles.dateText}>{new Date(r.createdAt).toLocaleDateString()}</span>
                     </div>
                     <div className={styles.col}>
                        <div className={styles.actionGroup}>
                            <button className={styles.iconActionBtn} title="Settings">
                               <Settings size={18} />
                            </button>
                            <button className={`${styles.iconActionBtn} ${styles.danger}`} title="Terminate" onClick={(e) => handleTerminate(r, e)}>
                               <Trash2 size={18} />
                            </button>
                            <button className={styles.expandBtn}>
                               <ChevronDown size={18} className={expandedId === r._id ? styles.rotated : ""} />
                            </button>
                        </div>
                     </div>
                  </div>

                  <AnimatePresence>
                     {expandedId === r._id && (
                        <motion.div 
                           initial={{ height: 0, opacity: 0 }}
                           animate={{ height: "auto", opacity: 1 }}
                           exit={{ height: 0, opacity: 0 }}
                           className={styles.expandedArea}
                        >
                           <div className={styles.tabs}>
                              <button className={styles.tabActive}>Overview</button>
                              <button className={styles.tab}>Configuration</button>
                              <button className={styles.tab}>{r.isApp ? 'Runtime' : 'Cloud Metadata'}</button>
                           </div>
                           <div className={styles.detailsGrid}>
                              <div className={styles.detailItem}>
                                 <label>Resource ID</label>
                                 <span>{r._id}</span>
                              </div>
                              <div className={styles.detailItem}>
                                 <label>{r.isApp ? 'Runtime' : 'Workspace'}</label>
                                 <span>{r.isApp ? (r.deploymentMethod === 'github' ? 'GitHub (Managed)' : 'Docker (Registry)') : (r.workspaceId || 'Default')}</span>
                              </div>
                              <div className={styles.detailItem}>
                                 <label>Provider</label>
                                 <span>Amazon Web Services (AWS)</span>
                              </div>
                              <div className={styles.detailItem}>
                                 <label>Last Updated</label>
                                 <span>{new Date(r.updatedAt).toLocaleString()}</span>
                              </div>
                           </div>

                           {r.isApp && (
                             <div className={styles.appActionsFooter}>
                                <div className={styles.actionPrompt}>Management Actions:</div>
                                <div className={styles.actionBtnGroup}>
                                   {r.status === 'stopped' ? (
                                     <button className={styles.appBtn} onClick={() => axios.post(`/api/applications/${r._id}/start`).then(fetchResources)}><Zap size={14} /> Start</button>
                                   ) : (
                                     <button className={styles.appBtn} onClick={() => axios.post(`/api/applications/${r._id}/stop`).then(fetchResources)}><Clock size={14} /> Stop</button>
                                   ) }
                                   <button className={styles.appBtn} onClick={() => axios.post(`/api/applications/${r._id}/redeploy`).then(fetchResources)}><RefreshCw size={14} /> Redeploy</button>
                                   <button className={styles.appBtn} onClick={() => router.push(`/dashboard/services/communication?appId=${r._id}`)}><Network size={14} /> Setup Comms</button>
                                   {r.url && <a href={r.url} target="_blank" className={styles.appBtn}><ExternalLink size={14} /> Visit App</a>}
                                </div>
                             </div>
                           )}
                        </motion.div>
                     )}
                  </AnimatePresence>
               </div>
            )) : (
               <div className={styles.emptyState}>
                  <Box size={48} />
                  <h3>No resources found</h3>
                  <p>You haven't deployed any infrastructure yet.</p>
                  <button className={styles.addBtn} onClick={() => router.push("/dashboard/services")}>Deploy Now</button>
               </div>
            )}
         </div>
      </div>
    </div>
  );
}
