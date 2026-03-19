"use client";
import React, { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { Database, ArrowLeft, Loader2, CheckCircle, AlertCircle, Terminal } from "lucide-react";
import { useRouter } from "next/navigation";
import styles from "../deploy.module.css";
import axios from "axios";
import { useAuth } from "@/contexts/AuthContext";

const ENGINES = ["mysql","postgres","aurora-mysql","aurora-postgresql","mariadb","sqlserver-se"];
const INSTANCE_CLASSES = ["db.t3.micro","db.t3.small","db.t3.medium","db.m5.large","db.m5.xlarge","db.r5.large"];
const AWS_REGIONS = ["us-east-1","us-east-2","us-west-1","us-west-2","ap-south-1","ap-southeast-1","eu-west-1","eu-central-1"];

export default function DeployRDS() {
  const { token } = useAuth() as any;
  const router = useRouter();
  const [accounts, setAccounts] = useState<any[]>([]);
  const [form, setForm] = useState({ awsAccountId: "", region: "us-east-1", resourceName: "", engine: "mysql",
    engineVersion: "8.0", instanceClass: "db.t3.micro", allocatedStorage: 20, dbName: "", masterUsername: "admin",
    masterPassword: "", multiAz: false, autoMinorVersionUpgrade: true, deletionProtection: true, backupRetentionPeriod: 7 });
  const [status, setStatus] = useState<null | "deploying" | "success" | "error">(null);
  const [logs, setLogs] = useState<string[]>([]);

  useEffect(() => {
    if (token) axios.get("/api/aws/accounts", { headers: { Authorization: `Bearer ${token}` } })
      .then(r => { setAccounts(r.data.accounts || []); if (r.data.accounts?.[0]) setForm(f => ({ ...f, awsAccountId: r.data.accounts[0]._id })); });
  }, [token]);

  const addLog = (msg: string) => setLogs(prev => [...prev, `[${new Date().toLocaleTimeString()}] ${msg}`]);

  const handleDeploy = async (e: React.FormEvent) => {
    e.preventDefault();
    setStatus("deploying"); setLogs([]);
    addLog("Initializing Terraform workspace...");
    addLog(`Provisioning RDS ${form.engine} in ${form.region}...`);
    try {
      const resp = await axios.post("/api/deploy/rds", { ...form, resourceType: "rds" }, { headers: { Authorization: `Bearer ${token}` } });
      addLog("✅ " + (resp.data.message || "RDS instance created!"));
      setStatus("success");
    } catch (err: any) {
      addLog(`❌ ${err.response?.data?.error || "Failed."}`);
      setStatus("error");
    }
  };

  return (
    <div className={styles.container}>
      <button className={styles.back} onClick={() => router.push("/dashboard/services")}><ArrowLeft size={18} /> Back to Services</button>
      <div className={styles.pageHeader}>
        <div className={styles.serviceIcon} style={{ background: "#f59e0b15", color: "#f59e0b" }}><Database size={28} /></div>
        <div><h1>Deploy RDS Database</h1><p>Provision a managed relational database with automated backups and high availability.</p></div>
      </div>
      <div className={styles.layout}>
        <form onSubmit={handleDeploy} className={styles.formCard}>
          <div className={styles.section}><h3>AWS Account</h3>
            {accounts.length === 0 ? <div className={styles.noAccount}>No AWS accounts. <button type="button" onClick={() => router.push("/dashboard/accounts")}>Connect →</button></div> :
              <div className={styles.fGroup}><label>Account</label>
                <select value={form.awsAccountId} onChange={e => setForm({ ...form, awsAccountId: e.target.value })}>
                  {accounts.map(a => <option key={a._id} value={a._id}>{a.accountName}</option>)}</select></div>}
          </div>
          <div className={styles.section}><h3>Database Engine</h3>
            <div className={styles.fGrid}>
              <div className={styles.fGroup}><label>Engine</label>
                <select value={form.engine} onChange={e => setForm({ ...form, engine: e.target.value })}>
                  {ENGINES.map(e => <option key={e} value={e}>{e}</option>)}</select></div>
              <div className={styles.fGroup}><label>Instance Class</label>
                <select value={form.instanceClass} onChange={e => setForm({ ...form, instanceClass: e.target.value })}>
                  {INSTANCE_CLASSES.map(c => <option key={c} value={c}>{c}</option>)}</select></div>
              <div className={styles.fGroup}><label>DB Identifier *</label>
                <input required placeholder="my-database" value={form.resourceName} onChange={e => setForm({ ...form, resourceName: e.target.value })} /></div>
              <div className={styles.fGroup}><label>Region</label>
                <select value={form.region} onChange={e => setForm({ ...form, region: e.target.value })}>
                  {AWS_REGIONS.map(r => <option key={r} value={r}>{r}</option>)}</select></div>
              <div className={styles.fGroup}><label>Master Username</label>
                <input value={form.masterUsername} onChange={e => setForm({ ...form, masterUsername: e.target.value })} /></div>
              <div className={styles.fGroup}><label>Master Password *</label>
                <input required type="password" placeholder="Min 8 chars" value={form.masterPassword} onChange={e => setForm({ ...form, masterPassword: e.target.value })} /></div>
              <div className={styles.fGroup}><label>Storage (GB)</label>
                <input type="number" min={20} max={1000} value={form.allocatedStorage} onChange={e => setForm({ ...form, allocatedStorage: +e.target.value })} /></div>
              <div className={styles.fGroup}><label>Backup Retention (days)</label>
                <input type="number" min={1} max={35} value={form.backupRetentionPeriod} onChange={e => setForm({ ...form, backupRetentionPeriod: +e.target.value })} /></div>
            </div>
            <div className={styles.toggleGrid}>
              {[{ key: "multiAz", label: "Multi-AZ" }, { key: "autoMinorVersionUpgrade", label: "Auto Minor Upgrade" }, { key: "deletionProtection", label: "Deletion Protection" }].map(opt => (
                <label key={opt.key} className={styles.toggle}><input type="checkbox" checked={(form as any)[opt.key]} onChange={e => setForm({ ...form, [opt.key]: e.target.checked })} /><span className={styles.toggleSlider} /><span>{opt.label}</span></label>
              ))}
            </div>
          </div>
          <button type="submit" className={styles.deployBtn} disabled={status === "deploying" || accounts.length === 0}>
            {status === "deploying" ? <><Loader2 size={18} className={styles.spin} /> Provisioning...</> : "🗄️ Deploy Database"}
          </button>
        </form>
        <div className={styles.logsCard}>
          <div className={styles.logsHeader}><Terminal size={18} /> Console
            {status === "success" && <span className={styles.successTag}><CheckCircle size={14} /> Success</span>}
            {status === "error" && <span className={styles.errorTag}><AlertCircle size={14} /> Failed</span>}
          </div>
          <div className={styles.logsBody}>
            {logs.length === 0 ? <p className={styles.logsPlaceholder}>Logs appear here.</p> :
              logs.map((l, i) => <motion.p key={i} initial={{ opacity: 0 }} animate={{ opacity: 1 }} className={styles.logLine}>{l}</motion.p>)}
          </div>
        </div>
      </div>
    </div>
  );
}
