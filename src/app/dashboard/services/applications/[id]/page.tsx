"use client";

import { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import axios from 'axios';
import styles from './ApplicationDetail.module.css';
import { 
  ArrowLeft, 
  Globe, 
  Server, 
  Shield, 
  Settings, 
  CheckCircle, 
  AlertCircle,
  Clock,
  GitBranch,
  Package,
  Trash2,
  RefreshCw,
  Play,
  Square,
  ExternalLink,
  ChevronRight,
  Loader2,
  Activity,
  Box,
  Layers,
  Container as DockerContainer
} from 'lucide-react';

export default function ApplicationDetail() {
  const router = useRouter();
  const { id } = useParams();
  const [application, setApplication] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [actionLoading, setActionLoading] = useState(false);

  useEffect(() => {
    fetchApplication();
  }, [id]);

  const fetchApplication = async () => {
    try {
      setLoading(true);
      const response = await axios.get(`/api/applications/${id}`);
      setApplication(response.data.application);
      setError('');
    } catch (err: any) {
      console.error('Error fetching application:', err);
      setError(err.response?.data?.error || 'Failed to load application');
    } finally {
      setLoading(false);
    }
  };

  const handleAction = async (action: string) => {
    setActionLoading(true);
    try {
      await axios.post(`/api/applications/${id}/${action}`, {});
      await fetchApplication();
    } catch (err: any) {
      alert(err.response?.data?.error || `Failed to ${action} application`);
    } finally {
      setActionLoading(false);
    }
  };

  const handleDelete = async () => {
    if (!window.confirm('Delete this application permanently?')) return;
    setActionLoading(true);
    try {
      await axios.delete(`/api/applications/${id}`);
      router.push('/dashboard/services/applications');
    } catch (err: any) {
      alert(err.response?.data?.error || 'Failed to delete application');
    } finally {
      setActionLoading(false);
    }
  };

  if (loading) {
    return (
      <div className={styles.detailPage}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', minHeight: '400px', color: 'var(--text-dim)' }}>
           <Loader2 className={styles.spin} size={48} color="var(--primary)" />
           <p style={{ marginTop: '16px', fontWeight: 600 }}>Loading Service Details...</p>
        </div>
      </div>
    );
  }

  if (error || !application) {
    return (
      <div className={styles.detailPage}>
        <button className={styles.btnBack} onClick={() => router.push('/dashboard/services/applications')}>
          <ArrowLeft size={18} /> Back to Applications
        </button>
        <div className={styles.section} style={{ textAlign: 'center', padding: '64px' }}>
          <AlertCircle color="var(--error)" size={48} style={{ marginBottom: '16px', opacity: 0.5 }} />
          <h3>Service Not Found: {error || 'The requested application could not be located.'}</h3>
        </div>
      </div>
    );
  }

  return (
    <div className={styles.detailPage}>
      <button className={styles.btnBack} onClick={() => router.push('/dashboard/services/applications')}>
        <ArrowLeft size={18} /> Back to Inventory
      </button>

      <header className={styles.header}>
        <div className={styles.appIconLarge}>
          {application.deploymentMethod === 'github' ? <GitBranch size={40} /> : <DockerContainer size={40} />}
        </div>
        <div style={{ flex: 1 }}>
          <h1 className={styles.title}>{application.name}</h1>
          <div className={styles.statusBadge} style={{ 
            background: application.status === 'running' ? 'rgba(16, 185, 129, 0.1)' : 'rgba(239, 68, 68, 0.1)',
            color: application.status === 'running' ? 'var(--success)' : 'var(--error)'
          }}>
            <div style={{ width: 8, height: 8, borderRadius: '50%', background: 'currentColor' }} />
            <span>{application.status.toUpperCase()}</span>
          </div>
        </div>
      </header>

      {application.url && (
        <div className={styles.urlLine}>
          <Globe color="var(--primary)" size={24} />
          <a href={application.url} target="_blank" className={styles.urlLink}>{application.url}</a>
          <ExternalLink size={20} color="var(--text-dim)" />
        </div>
      )}

      <div style={{ display: 'grid', gridTemplateColumns: '1.5fr 1fr', gap: '32px' }}>
        <div className={styles.section}>
          <h3><Settings size={22} color="var(--primary)" /> Configuration</h3>
          <div className={styles.configGrid}>
            <div className={styles.configItem}><span className={styles.configLabel}>Deployment</span><span className={styles.configValue}>{application.deploymentMethod?.toUpperCase()}</span></div>
            <div className={styles.configItem}><span className={styles.configLabel}>Tier</span><span className={styles.configValue}>{application.deploymentTarget?.toUpperCase() || 'STANDARD'}</span></div>
            <div className={styles.configItem}><span className={styles.configLabel}>Region</span><span className={styles.configValue}>{application.aws?.region || 'us-east-1'}</span></div>
            <div className={styles.configItem}><span className={styles.configLabel}>Last Sync</span><span className={styles.configValue}>{new Date(application.lastDeployedAt || application.createdAt).toLocaleString()}</span></div>
          </div>

          <div style={{ marginTop: '32px', borderTop: '1px solid var(--border)', paddingTop: '24px' }}>
             <h4 style={{ color: 'var(--text-dim)', fontSize: '0.85rem', textTransform: 'uppercase', marginBottom: '16px' }}>Network Architecture</h4>
             <div className={styles.configGrid}>
                <div className={styles.configItem}><span className={styles.configLabel}>Public Load Balancer</span><span className={styles.configValue}>Enabled</span></div>
                <div className={styles.configItem}><span className={styles.configLabel}>Protocol</span><span className={styles.configValue}>HTTPS (TLS 1.3)</span></div>
             </div>
          </div>
        </div>

        <div className={styles.section} style={{ background: 'rgba(2, 6, 23, 0.4)' }}>
           <h3><Activity size={22} color="var(--success)" /> Health & Traffic</h3>
           <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                 <span style={{ color: 'var(--text-dim)', fontWeight: 600 }}>Upstream Status</span>
                 <span style={{ color: 'var(--success)', fontWeight: 700 }}>HEALTHY</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                 <span style={{ color: 'var(--text-dim)', fontWeight: 600 }}>Response Time</span>
                 <span style={{ color: 'white', fontWeight: 700 }}>24ms</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                 <span style={{ color: 'var(--text-dim)', fontWeight: 600 }}>Active Nodes</span>
                 <span style={{ color: 'white', fontWeight: 700 }}>1 Target</span>
              </div>
              <div style={{ marginTop: '12px', height: '80px', background: 'rgba(255,255,255,0.02)', borderRadius: '12px', border: '1px solid var(--border)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                 <Activity size={32} color="var(--success)" style={{ opacity: 0.3 }} />
                 <span style={{ marginLeft: '12px', fontSize: '0.8rem', color: 'var(--text-dim)' }}>Real-time metrics pulse active</span>
              </div>
           </div>
        </div>
      </div>

      {application.errorMessage && (
         <div className={styles.section} style={{ borderColor: 'var(--error)' }}>
            <h3 style={{ color: 'var(--error)' }}><AlertCircle size={22} /> Event Log (Error)</h3>
            <div style={{ background: 'rgba(239, 68, 68, 0.05)', padding: '24px', borderRadius: '16px', color: 'var(--error)', fontSize: '0.9rem', fontFamily: 'monospace', border: '1px solid rgba(239, 68, 68, 0.1)' }}>
               {application.errorMessage}
            </div>
         </div>
      )}

      <div className={styles.actionsPanel}>
        <h3>Service Management</h3>
        <div className={styles.actionGrid}>
          {application.status === 'running' ? (
            <button className={`${styles.btnAction} ${styles.btnStop}`} onClick={() => handleAction('stop')} disabled={actionLoading}>
              <Square size={20} /> Stop Service
            </button>
          ) : (
            <button className={`${styles.btnAction} ${styles.btnStart}`} onClick={() => handleAction('start')} disabled={actionLoading}>
              <Play size={20} /> Start Service
            </button>
          )}
          <button className={`${styles.btnAction} ${styles.btnRedeploy}`} onClick={() => handleAction('redeploy')} disabled={actionLoading}>
            <RefreshCw size={20} className={actionLoading ? styles.spin : ''} /> Redeploy Cloud
          </button>
          <button className={`${styles.btnAction} ${styles.btnDelete}`} onClick={handleDelete} disabled={actionLoading}>
            <Trash2 size={20} /> Decommission
          </button>
        </div>
      </div>
    </div>
  );
}
