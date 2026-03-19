"use client";

import React, { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { Server, ArrowLeft, Loader2, CheckCircle, AlertCircle, Terminal } from "lucide-react";
import { useRouter } from "next/navigation";
import styles from "../deploy.module.css";
import axios from "axios";
import { useAuth } from "@/contexts/AuthContext";

const INSTANCE_TYPES = ["t3.micro","t3.small","t3.medium","t3.large","m5.large","m5.xlarge","c5.large","c5.xlarge","r5.large"];
const AWS_REGIONS = ["us-east-1","us-east-2","us-west-1","us-west-2","ap-south-1","ap-southeast-1","eu-west-1","eu-central-1"];
const AMIS = [
  { label: "Amazon Linux 2023", value: "ami-0c02fb55956c7d316" },
  { label: "Ubuntu 22.04 LTS", value: "ami-0557a15b87f6559cf" },
  { label: "Windows Server 2022", value: "ami-0c95efaa8d6f3f052" },
  { label: "RHEL 9", value: "ami-026ebd4cfe2c043b2" },
];

export default function DeployEC2() {
  const { token } = useAuth() as any;
  const router = useRouter();
  const [accounts, setAccounts] = useState<any[]>([]);
  const [form, setForm] = useState({
    awsAccountId: "", region: "us-east-1", resourceName: "",
    instanceType: "t3.micro", ami: AMIS[0].value,
    minCount: 1, maxCount: 1,
    enablePublicIp: true, multiAz: false, enableMonitoring: false,
    keyPair: "", securityGroups: "",
  });
  const [status, setStatus] = useState<null | "deploying" | "success" | "error">(null);
  const [logs, setLogs] = useState<string[]>([]);
  const [error, setError] = useState("");

  useEffect(() => {
    if (token) {
      axios.get("/api/aws/accounts", { headers: { Authorization: `Bearer ${token}` } })
        .then(r => { setAccounts(r.data.accounts || []); if (r.data.accounts?.[0]) setForm(f => ({ ...f, awsAccountId: r.data.accounts[0]._id })); })
        .catch(() => {});
    }
  }, [token]);

  const addLog = (msg: string) => setLogs(prev => [...prev, `[${new Date().toLocaleTimeString()}] ${msg}`]);

  const handleDeploy = async (e: React.FormEvent) => {
    e.preventDefault();
    setStatus("deploying");
    setLogs([]);
    setError("");
    addLog("Initializing Terraform workspace...");
    addLog("Validating AWS credentials...");
    addLog(`Provisioning EC2 instance (${form.instanceType}) in ${form.region}...`);

    try {
      const resp = await axios.post("/api/deploy/ec2", {
        ...form,
        resourceType: "ec2",
      }, { headers: { Authorization: `Bearer ${token}` } });

      addLog("Terraform plan complete.");
      addLog("Applying infrastructure changes...");
      addLog(`✅ ${resp.data.message || "EC2 instance deployed successfully!"}`);
      setStatus("success");
    } catch (err: any) {
      const msg = err.response?.data?.error || "Deployment failed.";
      addLog(`❌ Error: ${msg}`);
      setError(msg);
      setStatus("error");
    }
  };

  return (
    <div className={styles.container}>
      <button className={styles.back} onClick={() => router.push("/dashboard/services")}>
        <ArrowLeft size={18} /> Back to Services
      </button>

      <div className={styles.pageHeader}>
        <div className={styles.serviceIcon} style={{ background: "#3b82f615", color: "#3b82f6" }}>
          <Server size={28} />
        </div>
        <div>
          <h1>Deploy EC2 Instance</h1>
          <p>Configure and launch an AWS virtual machine with Terraform automation.</p>
        </div>
      </div>

      <div className={styles.layout}>
        <form onSubmit={handleDeploy} className={styles.formCard}>
          {/* AWS Account */}
          <div className={styles.section}>
            <h3>AWS Account</h3>
            {accounts.length === 0 ? (
              <div className={styles.noAccount}>
                No AWS accounts connected. <button type="button" onClick={() => router.push("/dashboard/accounts")}>Connect one →</button>
              </div>
            ) : (
              <div className={styles.fGroup}>
                <label>Select Account</label>
                <select value={form.awsAccountId} onChange={e => setForm({ ...form, awsAccountId: e.target.value })}>
                  {accounts.map(a => <option key={a._id} value={a._id}>{a.accountName} ({a.region})</option>)}
                </select>
              </div>
            )}
          </div>

          {/* Instance Config */}
          <div className={styles.section}>
            <h3>Instance Configuration</h3>
            <div className={styles.fGrid}>
              <div className={styles.fGroup}>
                <label>Resource Name *</label>
                <input required placeholder="e.g. web-server-prod" value={form.resourceName}
                  onChange={e => setForm({ ...form, resourceName: e.target.value })} />
              </div>
              <div className={styles.fGroup}>
                <label>Region *</label>
                <select value={form.region} onChange={e => setForm({ ...form, region: e.target.value })}>
                  {AWS_REGIONS.map(r => <option key={r} value={r}>{r}</option>)}
                </select>
              </div>
              <div className={styles.fGroup}>
                <label>Instance Type</label>
                <select value={form.instanceType} onChange={e => setForm({ ...form, instanceType: e.target.value })}>
                  {INSTANCE_TYPES.map(t => <option key={t} value={t}>{t}</option>)}
                </select>
              </div>
              <div className={styles.fGroup}>
                <label>AMI</label>
                <select value={form.ami} onChange={e => setForm({ ...form, ami: e.target.value })}>
                  {AMIS.map(a => <option key={a.value} value={a.value}>{a.label}</option>)}
                </select>
              </div>
              <div className={styles.fGroup}>
                <label>Min Count</label>
                <input type="number" min={1} max={20} value={form.minCount}
                  onChange={e => setForm({ ...form, minCount: +e.target.value })} />
              </div>
              <div className={styles.fGroup}>
                <label>Max Count</label>
                <input type="number" min={1} max={20} value={form.maxCount}
                  onChange={e => setForm({ ...form, maxCount: +e.target.value })} />
              </div>
            </div>
          </div>

          {/* Networking */}
          <div className={styles.section}>
            <h3>Networking</h3>
            <div className={styles.fGrid}>
              <div className={styles.fGroup}>
                <label>Key Pair Name</label>
                <input placeholder="my-keypair" value={form.keyPair}
                  onChange={e => setForm({ ...form, keyPair: e.target.value })} />
              </div>
              <div className={styles.fGroup}>
                <label>Security Groups (comma-separated)</label>
                <input placeholder="sg-xxxxxxxx, sg-yyyyyyyy" value={form.securityGroups}
                  onChange={e => setForm({ ...form, securityGroups: e.target.value })} />
              </div>
            </div>
            <div className={styles.toggleGrid}>
              {[
                { key: "enablePublicIp", label: "Public IP" },
                { key: "multiAz", label: "Multi-AZ HA" },
                { key: "enableMonitoring", label: "Detailed Monitoring" },
              ].map(opt => (
                <label key={opt.key} className={styles.toggle}>
                  <input type="checkbox" checked={(form as any)[opt.key]}
                    onChange={e => setForm({ ...form, [opt.key]: e.target.checked })} />
                  <span className={styles.toggleSlider} />
                  <span>{opt.label}</span>
                </label>
              ))}
            </div>
          </div>

          <button type="submit" className={styles.deployBtn} disabled={status === "deploying" || accounts.length === 0}>
            {status === "deploying" ? (
              <><Loader2 size={18} className={styles.spin} /> Deploying...</>
            ) : "🚀 Deploy with Terraform"}
          </button>
        </form>

        {/* Logs panel */}
        <div className={styles.logsCard}>
          <div className={styles.logsHeader}>
            <Terminal size={18} /> Deployment Console
            {status === "success" && <span className={styles.successTag}><CheckCircle size={14} /> Success</span>}
            {status === "error" && <span className={styles.errorTag}><AlertCircle size={14} /> Failed</span>}
          </div>
          <div className={styles.logsBody}>
            {logs.length === 0 ? (
              <p className={styles.logsPlaceholder}>Console output will appear here when you deploy.</p>
            ) : (
              logs.map((l, i) => (
                <motion.p key={i} initial={{ opacity: 0, x: -6 }} animate={{ opacity: 1, x: 0 }} className={styles.logLine}>
                  {l}
                </motion.p>
              ))
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
