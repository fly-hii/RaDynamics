"use client";

import React, { useState, useEffect } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  Plus, Trash2, CheckCircle, XCircle, Shield, Globe, Server,
  ChevronDown, Loader2, Eye, EyeOff, Star, AlertCircle
} from "lucide-react";
import styles from "./page.module.css";
import axios from "axios";
import { useAuth } from "@/contexts/AuthContext";

const AWS_REGIONS = [
  "us-east-1","us-east-2","us-west-1","us-west-2","ap-south-1",
  "ap-southeast-1","ap-southeast-2","ap-northeast-1","eu-west-1","eu-central-1",
  "sa-east-1","ca-central-1","me-south-1","af-south-1",
];

export default function AccountsPage() {
  const { token } = useAuth() as any;
  const [accounts, setAccounts] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  const [success, setSuccess] = useState("");
  const [error, setError] = useState("");
  const [showSecret, setShowSecret] = useState(false);

  const [form, setForm] = useState({
    accountName: "", accountId: "", accountType: "production",
    accessKey: "", secretKey: "", region: "us-east-1", description: "",
  });

  const fetchAccounts = async () => {
    try {
      const resp = await axios.get("/api/aws/accounts", {
        headers: { Authorization: `Bearer ${token}` },
      });
      setAccounts(resp.data.accounts || []);
    } catch {}
    setLoading(false);
  };

  useEffect(() => { if (token) fetchAccounts(); }, [token]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitting(true);
    setError("");
    setSuccess("");
    try {
      const resp = await axios.post("/api/aws/accounts", form, {
        headers: { Authorization: `Bearer ${token}` },
      });
      setSuccess(resp.data.verified
        ? "✅ Account connected and verified successfully!"
        : "⚠️ Account saved but credentials could not be verified. Check your keys.");
      setForm({ accountName: "", accountId: "", accountType: "production", accessKey: "", secretKey: "", region: "us-east-1", description: "" });
      setShowForm(false);
      fetchAccounts();
    } catch (err: any) {
      setError(err.response?.data?.error || "Failed to connect account.");
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Remove this AWS account?")) return;
    try {
      await axios.delete(`/api/aws/accounts?id=${id}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      setAccounts(prev => prev.filter(a => a._id !== id));
    } catch {}
  };

  return (
    <div className={styles.container}>
      <div className={styles.hdr}>
        <div>
          <h1>AWS Accounts</h1>
          <p>Connect and manage your AWS account credentials securely.</p>
        </div>
        <button className={styles.addBtn} onClick={() => setShowForm(true)}>
          <Plus size={18} /> Connect Account
        </button>
      </div>

      {success && (
        <motion.div initial={{ opacity: 0, y: -10 }} animate={{ opacity: 1, y: 0 }} className={styles.successBanner}>
          <CheckCircle size={18} /> {success}
        </motion.div>
      )}

      {/* Account cards */}
      {loading ? (
        <div className={styles.loader}><Loader2 size={32} className={styles.spin} /></div>
      ) : accounts.length === 0 ? (
        <div className={styles.empty}>
          <Server size={48} />
          <h3>No AWS accounts connected</h3>
          <p>Connect your first AWS account to start deploying infrastructure.</p>
          <button className={styles.addBtn} onClick={() => setShowForm(true)}>
            <Plus size={18} /> Connect First Account
          </button>
        </div>
      ) : (
        <div className={styles.accountGrid}>
          {accounts.map((acc, i) => (
            <motion.div key={acc._id} initial={{ opacity: 0, y: 16 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.08 }} className={styles.accountCard}>
              <div className={styles.accTop}>
                <div className={styles.accIcon}><Server size={22} /></div>
                <div className={styles.accMeta}>
                  <div className={styles.accNameRow}>
                    <h4>{acc.accountName}</h4>
                    {acc.isPrimary && <span className={styles.primaryBadge}><Star size={12} /> Primary</span>}
                  </div>
                  <span className={styles.accType}>{acc.accountType} • {acc.region}</span>
                </div>
                <div className={`${styles.verifiedBadge} ${acc.verified ? styles.ok : styles.warn}`}>
                  {acc.verified ? <><CheckCircle size={14} /> Verified</> : <><AlertCircle size={14} /> Unverified</>}
                </div>
              </div>
              {acc.accountId && <p className={styles.accId}>Account ID: {acc.accountId}</p>}
              {acc.description && <p className={styles.accDesc}>{acc.description}</p>}
              <div className={styles.accFooter}>
                <span className={styles.accDate}>Added {new Date(acc.createdAt).toLocaleDateString()}</span>
                <button className={styles.deleteBtn} onClick={() => handleDelete(acc._id)}>
                  <Trash2 size={16} /> Remove
                </button>
              </div>
            </motion.div>
          ))}
        </div>
      )}

      {/* Add Account Modal */}
      <AnimatePresence>
        {showForm && (
          <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} exit={{ opacity: 0 }} className={styles.overlay}>
            <motion.div initial={{ scale: 0.95, y: 20 }} animate={{ scale: 1, y: 0 }} exit={{ scale: 0.95 }} className={styles.modal}>
              <div className={styles.modalHeader}>
                <h2>Connect AWS Account</h2>
                <button className={styles.closeBtn} onClick={() => setShowForm(false)}>✕</button>
              </div>

              <form onSubmit={handleSubmit} className={styles.form}>
                <div className={styles.formRow}>
                  <div className={styles.formGroup}>
                    <label>Account Name *</label>
                    <input required placeholder="e.g. Production-US" value={form.accountName}
                      onChange={e => setForm({ ...form, accountName: e.target.value })} />
                  </div>
                  <div className={styles.formGroup}>
                    <label>AWS Account ID</label>
                    <input placeholder="123456789012" value={form.accountId}
                      onChange={e => setForm({ ...form, accountId: e.target.value })} />
                  </div>
                </div>
                <div className={styles.formRow}>
                  <div className={styles.formGroup}>
                    <label>Account Type</label>
                    <select value={form.accountType} onChange={e => setForm({ ...form, accountType: e.target.value })}>
                      {["production","staging","development","testing","sandbox"].map(t => (
                        <option key={t} value={t}>{t.charAt(0).toUpperCase() + t.slice(1)}</option>
                      ))}
                    </select>
                  </div>
                  <div className={styles.formGroup}>
                    <label>Default Region *</label>
                    <select value={form.region} onChange={e => setForm({ ...form, region: e.target.value })}>
                      {AWS_REGIONS.map(r => <option key={r} value={r}>{r}</option>)}
                    </select>
                  </div>
                </div>
                <div className={styles.formGroup}>
                  <label>Access Key ID *</label>
                  <input required placeholder="AKIA..." value={form.accessKey}
                    onChange={e => setForm({ ...form, accessKey: e.target.value })} />
                </div>
                <div className={styles.formGroup}>
                  <label>Secret Access Key *</label>
                  <div className={styles.secretWrap}>
                    <input required type={showSecret ? "text" : "password"} placeholder="Secret key..."
                      value={form.secretKey} onChange={e => setForm({ ...form, secretKey: e.target.value })} />
                    <button type="button" onClick={() => setShowSecret(!showSecret)}>
                      {showSecret ? <EyeOff size={16} /> : <Eye size={16} />}
                    </button>
                  </div>
                </div>
                <div className={styles.formGroup}>
                  <label>Description</label>
                  <input placeholder="Optional description" value={form.description}
                    onChange={e => setForm({ ...form, description: e.target.value })} />
                </div>

                {error && <p className={styles.err}>{error}</p>}

                <div className={styles.securityNote}>
                  <Shield size={16} /> Credentials are encrypted with AES-256 before storage.
                </div>

                <div className={styles.modalActions}>
                  <button type="button" className={styles.cancelBtn} onClick={() => setShowForm(false)}>Cancel</button>
                  <button type="submit" className={styles.confirmBtn} disabled={submitting}>
                    {submitting ? <><Loader2 size={16} className={styles.spin} /> Connecting...</> : "Connect & Verify"}
                  </button>
                </div>
              </form>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
