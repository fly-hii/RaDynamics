"use client";

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import axios from 'axios';
import styles from './Applications.module.css';
import { 
  RefreshCw, Trash2, ExternalLink, Plus, Server, GitBranch, Package,
  Eye, AlertCircle, Activity, Box, ChevronRight, Play, Square, 
  Loader2, Container as DockerContainer, Info
} from 'lucide-react';

export default function Applications() {
  const router = useRouter();
  const [applications, setApplications] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [actionLoading, setActionLoading] = useState<Record<string, string | null>>({});
  const [filter, setFilter] = useState('all');

  useEffect(() => {
    fetchApplications();
  }, []);

  const fetchApplications = async () => {
    try {
      setLoading(true);
      const response = await axios.get('/api/applications');
      setApplications(response.data.applications || []);
      setError('');
    } catch (err: any) {
      console.error('Error fetching applications:', err);
      setError(err.response?.data?.error || 'Failed to load applications');
    } finally {
      setLoading(false);
    }
  };

  const handleAction = async (appId: string, action: string) => {
    setActionLoading(prev => ({ ...prev, [appId]: action }));
    try {
      await axios.post(`/api/applications/${appId}/${action}`, {});
      await fetchApplications();
    } catch (error: any) {
      alert(error.response?.data?.error || `Failed to ${action} application`);
    } finally {
      setActionLoading(prev => ({ ...prev, [appId]: null }));
    }
  };

  const handleDelete = async (appId: string) => {
    if (!window.confirm('Delete this application permanently?')) return;
    setActionLoading(prev => ({ ...prev, [appId]: 'delete' }));
    try {
      await axios.delete(`/api/applications/${appId}`);
      await fetchApplications();
    } catch (error: any) {
      alert(error.response?.data?.error || 'Failed to delete application');
    } finally {
      setActionLoading(prev => ({ ...prev, [appId]: null }));
    }
  };

  const getStatusClass = (status: string) => {
    switch(status) {
      case 'running': return styles.running;
      case 'stopped': return styles.stopped;
      case 'pending':
      case 'building':
      case 'deploying': return styles.pending;
      case 'failed':
      case 'error': return styles.failed;
      default: return '';
    }
  };

  const filteredApplications = applications.filter(app => {
    if (filter === 'all') return true;
    if (filter === 'running') return app.status === 'running';
    if (filter === 'stopped') return app.status === 'stopped';
    return true;
  });

  const getFilterCount = (f: string) => {
    if (f === 'all') return applications.length;
    return applications.filter(app => app.status === f).length;
  };

  if (loading && applications.length === 0) {
    return (
      <div className={styles.container}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', minHeight: '400px', color: 'var(--text-dim)' }}>
          <Loader2 className={styles.spin} size={48} color="var(--primary)" />
          <p style={{ marginTop: '16px', fontWeight: 600 }}>Syncing Services...</p>
        </div>
      </div>
    );
  }

  return (
    <div className={styles.container}>
      {/* Header */}
      <div className={styles.header}>
        <div className={styles.headerInfo}>
          <h1>Services Inventory</h1>
          <p>Global view of your cloud-deployed application services.</p>
        </div>
        <div className={styles.headerActions}>
           <button className={`${styles.btn} ${styles.btnSecondary}`} onClick={fetchApplications} title="Refresh Inventory">
            <RefreshCw size={18} className={loading ? styles.spin : ''} />
          </button>
          <button className={`${styles.btn} ${styles.btnPrimary}`} onClick={() => router.push('/dashboard/services/deploy/app')}>
            <Plus size={18} /> New Service
          </button>
        </div>
      </div>

      {/* Stats Summary */}
      <div className={styles.statsGrid}>
        <div className={styles.statCard}>
          <div className={styles.statIcon} style={{ background: 'rgba(0, 98, 255, 0.1)', color: 'var(--primary)' }}><Box size={20} /></div>
          <div>
            <div className={styles.statLabel}>Total</div>
            <div className={styles.statValue}>{applications.length}</div>
          </div>
        </div>
        <div className={styles.statCard}>
          <div className={styles.statIcon} style={{ background: 'rgba(16, 185, 129, 0.1)', color: 'var(--success)' }}><Activity size={20} /></div>
          <div>
            <div className={styles.statLabel}>Up</div>
            <div className={styles.statValue}>{applications.filter(a => a.status === 'running').length}</div>
          </div>
        </div>
        <div className={styles.statCard}>
          <div className={styles.statIcon} style={{ background: 'rgba(99, 102, 241, 0.1)', color: '#6366f1' }}><GitBranch size={20} /></div>
          <div>
            <div className={styles.statLabel}>GitHub</div>
            <div className={styles.statValue}>{applications.filter(a => a.deploymentMethod === 'github').length}</div>
          </div>
        </div>
        <div className={styles.statCard}>
          <div className={styles.statIcon} style={{ background: 'rgba(14, 165, 233, 0.1)', color: '#0ea5e9' }}><DockerContainer size={20} /></div>
          <div>
            <div className={styles.statLabel}>Docker</div>
            <div className={styles.statValue}>{applications.filter(a => a.deploymentMethod === 'docker').length}</div>
          </div>
        </div>
      </div>

      {/* Main Grid */}
      <div className={styles.mainCard}>
        <div className={styles.sectionHeader}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
            <h2 style={{ fontSize: '1.25rem', color: 'white' }}>Active Deployments</h2>
            <div title="This list shows all apps you've deployed regardless of target." style={{ color: 'var(--text-dim)', cursor: 'help' }}>
               <Info size={16} />
            </div>
          </div>
          <div className={styles.filterButtons}>
            <button className={`${styles.filterBtn} ${filter === 'all' ? styles.active : ''}`} onClick={() => setFilter('all')}>
              All <span style={{ opacity: 0.5, fontSize: '0.7rem', marginLeft: '4px' }}>{getFilterCount('all')}</span>
            </button>
            <button className={`${styles.filterBtn} ${filter === 'running' ? styles.active : ''}`} onClick={() => setFilter('running')}>
              <div style={{ width: 6, height: 6, borderRadius: '50%', background: '#10b981' }} />
              Running <span style={{ opacity: 0.5, fontSize: '0.7rem', marginLeft: '4px' }}>{getFilterCount('running')}</span>
            </button>
            <button className={`${styles.filterBtn} ${filter === 'stopped' ? styles.active : ''}`} onClick={() => setFilter('stopped')}>
              <div style={{ width: 6, height: 6, borderRadius: '50%', background: '#94a3b8' }} />
              Stopped <span style={{ opacity: 0.5, fontSize: '0.7rem', marginLeft: '4px' }}>{getFilterCount('stopped')}</span>
            </button>
          </div>
        </div>

        <div className={styles.appGrid}>
          {filteredApplications.map(app => (
            <div key={app._id} className={styles.appCard}>
              <div className={styles.appHeader}>
                <div className={styles.statusBadge}>
                  {app.deploymentMethod === 'github' ? <GitBranch size={12} /> : <Package size={12} />}
                  <span>{app.deploymentMethod}</span>
                </div>
                <div className={`${styles.statusBadge} ${getStatusClass(app.status)}`}>
                  <span>{app.status}</span>
                </div>
              </div>

              <h3 className={styles.appName}>{app.name}</h3>

              {app.url && (
                <a href={app.url} target="_blank" className={styles.appUrl}>
                  <ExternalLink size={14} />
                  <span style={{ flex: 1, overflow: 'hidden', textOverflow: 'ellipsis' }}>{app.url.replace('https://', '')}</span>
                </a>
              )}

              <div className={styles.appDetails}>
                <div className={styles.detailRow}>
                  <span>Target</span>
                  <span>{app.deploymentTarget || 'ECS'}</span>
                </div>
                <div className={styles.detailRow}>
                  <span>Region</span>
                  <span>{app.aws?.region || 'us-east-1'}</span>
                </div>
              </div>

              <div className={styles.appActions}>
                <button className={styles.actionBtn} onClick={() => router.push(`/dashboard/services/applications/${app._id}`)} title="View Management Dashboard">
                  <Eye size={16} />
                </button>
                <button className={styles.actionBtn} onClick={() => handleAction(app._id, 'redeploy')} disabled={!!actionLoading[app._id]} title="Re-sync and Redeploy">
                  <RefreshCw size={16} className={actionLoading[app._id] === 'redeploy' ? styles.spin : ''} />
                </button>
                {app.status === 'running' ? (
                  <button className={styles.actionBtn} style={{ color: 'var(--error)' }} onClick={() => handleAction(app._id, 'stop')} disabled={!!actionLoading[app._id]} title="Stop Service">
                    <Square size={16} />
                  </button>
                ) : (
                  <button className={styles.actionBtn} style={{ color: 'var(--success)' }} onClick={() => handleAction(app._id, 'start')} disabled={!!actionLoading[app._id]} title="Start Service">
                    <Play size={16} />
                  </button>
                )}
                <button className={styles.actionBtn} style={{ color: 'var(--error)' }} onClick={() => handleDelete(app._id)} disabled={!!actionLoading[app._id]} title="Terminate & Delete">
                  <Trash2 size={16} />
                </button>
              </div>
            </div>
          ))}
          {filteredApplications.length === 0 && (
            <div style={{ gridColumn: '1/-1', textAlign: 'center', padding: '60px', color: 'var(--text-dim)' }}>
               <Box size={40} style={{ marginBottom: '12px', opacity: 0.3 }} />
               <p style={{ fontSize: '0.9rem' }}>No services found in this category.</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
