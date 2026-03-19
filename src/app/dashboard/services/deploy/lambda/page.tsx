"use client";
import React, { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { Zap, ArrowLeft, Loader2, CheckCircle, AlertCircle, Terminal, Cpu } from "lucide-react";
import { useRouter } from "next/navigation";
import styles from "../deploy.module.css";
import axios from "axios";
import { useAuth } from "@/contexts/AuthContext";

const AWS_REGIONS = ["us-east-1","us-east-2","us-west-1","us-west-2","ap-south-1","ap-southeast-1","eu-west-1","eu-central-1"];
const RUNTIMES = ["python3.9", "python3.10", "nodejs18.x", "nodejs20.x", "go1.x", "java11"];

export default function DeployLambda() {
  const { token } = useAuth() as any;
  const router = useRouter();
  const [accounts, setAccounts] = useState<any[]>([]);
  const [form, setForm] = useState({ 
    awsAccountId: "", 
    region: "us-east-1", 
    resourceName: "", 
    function_name: "",
    handler: "lambda_function.lambda_handler",
    runtime: "python3.10",
    memory_size: 128,
    timeout: 3,
    description: "Serverless function created via RayDynamics"
  });
  const [status, setStatus] = useState<null | "deploying" | "success" | "error">(null);
  const [logs, setLogs] = useState<string[]>([]);

  useEffect(() => {
    if (token) axios.get("/api/aws/accounts", { headers: { Authorization: `Bearer ${token}` } })
      .then(r => { 
        setAccounts(r.data.accounts || []); 
        if (r.data.accounts?.[0]) setForm(f => ({ ...f, awsAccountId: r.data.accounts[0]._id })); 
      });
  }, [token]);

  const addLog = (msg: string) => setLogs(prev => [...prev, `[${new Date().toLocaleTimeString()}] ${msg}`]);

  const handleDeploy = async (e: React.FormEvent) => {
    e.preventDefault();
    setStatus("deploying"); setLogs([]);
    addLog("Initializing Terraform workspace...");
    addLog(`Creating Lambda function: ${form.resourceName || form.function_name}...`);
    addLog(`Runtime: ${form.runtime}, Memory: ${form.memory_size}MB...`);
    
    try {
      const resp = await axios.post("/api/deploy/lambda", { 
        ...form, 
        resourceType: "lambda",
        function_name: form.resourceName || form.function_name
      }, { headers: { Authorization: `Bearer ${token}` } });
      
      addLog("✅ " + (resp.data.message || "Lambda function deployed successfully!"));
      setStatus("success");
    } catch (err: any) {
      addLog(`❌ ${err.response?.data?.error || "Deployment failed."}`);
      setStatus("error");
    }
  };

  return (
    <div className={styles.container}>
      <button className={styles.back} onClick={() => router.push("/dashboard/services")}><ArrowLeft size={18} /> Back to Services</button>
      <div className={styles.pageHeader}>
        <div className={styles.serviceIcon} style={{ background: "#6366f115", color: "#6366f1" }}><Zap size={28} /></div>
        <div><h1>Deploy Lambda Function</h1><p>Provision event-driven serverless functions with automatic scaling.</p></div>
      </div>
      <div className={styles.layout}>
        <form onSubmit={handleDeploy} className={styles.formCard}>
          <div className={styles.section}><h3>AWS Account</h3>
            {accounts.length === 0 ? <div className={styles.noAccount}>No accounts. <button type="button" onClick={() => router.push("/dashboard/accounts")}>Connect →</button></div> :
              <div className={styles.fGroup}><label>Account</label>
                <select value={form.awsAccountId} onChange={e => setForm({ ...form, awsAccountId: e.target.value })}>
                  {accounts.map(a => <option key={a._id} value={a._id}>{a.accountName}</option>)}</select></div>}
          </div>
          <div className={styles.section}><h3>Function Configuration</h3>
            <div className={styles.fGrid}>
              <div className={styles.fGroup}><label>Function Name *</label>
                <input required placeholder="my-serverless-fn" value={form.resourceName} onChange={e => setForm({ ...form, resourceName: e.target.value, function_name: e.target.value })} /></div>
              <div className={styles.fGroup}><label>Region</label>
                <select value={form.region} onChange={e => setForm({ ...form, region: e.target.value })}>
                  {AWS_REGIONS.map(r => <option key={r} value={r}>{r}</option>)}</select></div>
              <div className={styles.fGroup}><label>Runtime</label>
                <select value={form.runtime} onChange={e => setForm({ ...form, runtime: e.target.value })}>
                  {RUNTIMES.map(rt => <option key={rt} value={rt}>{rt}</option>)}</select></div>
              <div className={styles.fGroup}><label>Handler</label>
                <input value={form.handler} onChange={e => setForm({ ...form, handler: e.target.value })} /></div>
              <div className={styles.fGroup}><label>Memory (MB)</label>
                <input type="number" step={64} min={128} max={3008} value={form.memory_size} onChange={e => setForm({ ...form, memory_size: +e.target.value })} /></div>
              <div className={styles.fGroup}><label>Timeout (sec)</label>
                <input type="number" min={1} max={900} value={form.timeout} onChange={e => setForm({ ...form, timeout: +e.target.value })} /></div>
            </div>
          </div>
          <button type="submit" className={styles.deployBtn} disabled={status === "deploying" || accounts.length === 0}>
            {status === "deploying" ? <><Loader2 size={18} className={styles.spin} /> Deploying...</> : <><Zap size={18} /> Deploy Lambda</>}
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
