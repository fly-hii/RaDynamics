"use client";
import React, { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { Box, ArrowLeft, Loader2, CheckCircle, AlertCircle, Terminal } from "lucide-react";
import { useRouter } from "next/navigation";
import styles from "../deploy.module.css";
import axios from "axios";
import { useAuth } from "@/contexts/AuthContext";

const AWS_REGIONS = ["us-east-1","us-east-2","us-west-1","us-west-2","ap-south-1","ap-southeast-1","eu-west-1","eu-central-1"];

export default function DeployS3() {
  const { token } = useAuth() as any;
  const router = useRouter();
  const [accounts, setAccounts] = useState<any[]>([]);
  const [form, setForm] = useState({ awsAccountId: "", region: "us-east-1", resourceName: "", versioning: true, encryption: true, publicAccess: false, intelligentTiering: false });
  const [status, setStatus] = useState<null | "deploying" | "success" | "error">(null);
  const [logs, setLogs] = useState<string[]>([]);
  const [error, setError] = useState("");

  useEffect(() => {
    if (token) axios.get("/api/aws/accounts", { headers: { Authorization: `Bearer ${token}` } })
      .then(r => { setAccounts(r.data.accounts || []); if (r.data.accounts?.[0]) setForm(f => ({ ...f, awsAccountId: r.data.accounts[0]._id })); });
  }, [token]);

  const addLog = (msg: string) => setLogs(prev => [...prev, `[${new Date().toLocaleTimeString()}] ${msg}`]);

  const handleDeploy = async (e: React.FormEvent) => {
    e.preventDefault();
    setStatus("deploying"); setLogs([]); setError("");
    addLog("Initializing Terraform workspace...");
    addLog(`Creating S3 bucket: ${form.resourceName} in ${form.region}...`);
    try {
      const resp = await axios.post("/api/deploy/s3", { ...form, resourceType: "s3" }, { headers: { Authorization: `Bearer ${token}` } });
      addLog("✅ " + (resp.data.message || "S3 bucket created successfully!"));
      setStatus("success");
    } catch (err: any) {
      const msg = err.response?.data?.error || "Deployment failed.";
      addLog(`❌ Error: ${msg}`);
      setError(msg); setStatus("error");
    }
  };

  return (
    <div className={styles.container}>
      <button className={styles.back} onClick={() => router.push("/dashboard/services")}><ArrowLeft size={18} /> Back to Services</button>
      <div className={styles.pageHeader}>
        <div className={styles.serviceIcon} style={{ background: "#10b98115", color: "#10b981" }}><Box size={28} /></div>
        <div><h1>Create S3 Bucket</h1><p>Create a secure, encrypted object storage bucket with lifecycle management.</p></div>
      </div>
      <div className={styles.layout}>
        <form onSubmit={handleDeploy} className={styles.formCard}>
          <div className={styles.section}>
            <h3>AWS Account</h3>
            {accounts.length === 0 ? (
              <div className={styles.noAccount}>No AWS accounts connected. <button type="button" onClick={() => router.push("/dashboard/accounts")}>Connect one →</button></div>
            ) : (
              <div className={styles.fGroup}><label>Select Account</label>
                <select value={form.awsAccountId} onChange={e => setForm({ ...form, awsAccountId: e.target.value })}>
                  {accounts.map(a => <option key={a._id} value={a._id}>{a.accountName} ({a.region})</option>)}
                </select>
              </div>
            )}
          </div>
          <div className={styles.section}>
            <h3>Bucket Configuration</h3>
            <div className={styles.fGrid}>
              <div className={styles.fGroup}><label>Bucket Name *</label>
                <input required placeholder="my-bucket-name" value={form.resourceName} onChange={e => setForm({ ...form, resourceName: e.target.value })} /></div>
              <div className={styles.fGroup}><label>Region *</label>
                <select value={form.region} onChange={e => setForm({ ...form, region: e.target.value })}>
                  {AWS_REGIONS.map(r => <option key={r} value={r}>{r}</option>)}</select></div>
            </div>
            <div className={styles.toggleGrid}>
              {[
                { key: "versioning", label: "Versioning" },
                { key: "encryption", label: "AES-256 Encryption" },
                { key: "publicAccess", label: "Allow Public Access" },
                { key: "intelligentTiering", label: "Intelligent Tiering" },
              ].map(opt => (
                <label key={opt.key} className={styles.toggle}>
                  <input type="checkbox" checked={(form as any)[opt.key]} onChange={e => setForm({ ...form, [opt.key]: e.target.checked })} />
                  <span className={styles.toggleSlider} /><span>{opt.label}</span>
                </label>
              ))}
            </div>
          </div>
          <button type="submit" className={styles.deployBtn} disabled={status === "deploying" || accounts.length === 0}>
            {status === "deploying" ? <><Loader2 size={18} className={styles.spin} /> Creating...</> : "🪣 Create Bucket"}
          </button>
        </form>
        <div className={styles.logsCard}>
          <div className={styles.logsHeader}><Terminal size={18} /> Deployment Console
            {status === "success" && <span className={styles.successTag}><CheckCircle size={14} /> Success</span>}
            {status === "error" && <span className={styles.errorTag}><AlertCircle size={14} /> Failed</span>}
          </div>
          <div className={styles.logsBody}>
            {logs.length === 0 ? <p className={styles.logsPlaceholder}>Console output will appear here.</p> :
              logs.map((l, i) => <motion.p key={i} initial={{ opacity: 0 }} animate={{ opacity: 1 }} className={styles.logLine}>{l}</motion.p>)}
          </div>
        </div>
      </div>
    </div>
  );
}
