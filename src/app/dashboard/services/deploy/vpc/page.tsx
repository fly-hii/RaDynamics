"use client";
import React, { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { Network, ArrowLeft, Loader2, CheckCircle, AlertCircle, Terminal } from "lucide-react";
import { useRouter } from "next/navigation";
import styles from "../deploy.module.css";
import axios from "axios";
import { useAuth } from "@/contexts/AuthContext";

const AWS_REGIONS = ["us-east-1","us-east-2","us-west-1","us-west-2","ap-south-1","ap-southeast-1","eu-west-1","eu-central-1"];

export default function DeployVPC() {
  const { token } = useAuth() as any;
  const router = useRouter();
  const [accounts, setAccounts] = useState<any[]>([]);
  const [form, setForm] = useState({ awsAccountId: "", region: "us-east-1", resourceName: "",
    cidrBlock: "10.0.0.0/16", publicSubnetCidr: "10.0.1.0/24", privateSubnetCidr: "10.0.2.0/24",
    enableNatGateway: true, enableDnsHostnames: true, enableFlowLogs: false });
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
    addLog(`Creating VPC ${form.resourceName} (${form.cidrBlock}) in ${form.region}...`);
    addLog("Configuring subnets, route tables, internet gateway...");
    if (form.enableNatGateway) addLog("Attaching NAT gateway...");
    try {
      const resp = await axios.post("/api/deploy/vpc", { ...form, resourceType: "vpc" }, { headers: { Authorization: `Bearer ${token}` } });
      addLog("✅ " + (resp.data.message || "VPC created successfully!"));
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
        <div className={styles.serviceIcon} style={{ background: "#8b5cf615", color: "#8b5cf6" }}><Network size={28} /></div>
        <div><h1>Create VPC Network</h1><p>Provision an isolated virtual network with custom subnets and routing.</p></div>
      </div>
      <div className={styles.layout}>
        <form onSubmit={handleDeploy} className={styles.formCard}>
          <div className={styles.section}><h3>AWS Account</h3>
            {accounts.length === 0 ? <div className={styles.noAccount}>No accounts. <button type="button" onClick={() => router.push("/dashboard/accounts")}>Connect →</button></div> :
              <div className={styles.fGroup}><label>Account</label>
                <select value={form.awsAccountId} onChange={e => setForm({ ...form, awsAccountId: e.target.value })}>
                  {accounts.map(a => <option key={a._id} value={a._id}>{a.accountName}</option>)}</select></div>}
          </div>
          <div className={styles.section}><h3>VPC Configuration</h3>
            <div className={styles.fGrid}>
              <div className={styles.fGroup}><label>VPC Name *</label>
                <input required placeholder="my-vpc-prod" value={form.resourceName} onChange={e => setForm({ ...form, resourceName: e.target.value })} /></div>
              <div className={styles.fGroup}><label>Region</label>
                <select value={form.region} onChange={e => setForm({ ...form, region: e.target.value })}>
                  {AWS_REGIONS.map(r => <option key={r} value={r}>{r}</option>)}</select></div>
              <div className={styles.fGroup}><label>CIDR Block</label>
                <input value={form.cidrBlock} onChange={e => setForm({ ...form, cidrBlock: e.target.value })} /></div>
              <div className={styles.fGroup}><label>Public Subnet CIDR</label>
                <input value={form.publicSubnetCidr} onChange={e => setForm({ ...form, publicSubnetCidr: e.target.value })} /></div>
              <div className={styles.fGroup}><label>Private Subnet CIDR</label>
                <input value={form.privateSubnetCidr} onChange={e => setForm({ ...form, privateSubnetCidr: e.target.value })} /></div>
            </div>
            <div className={styles.toggleGrid}>
              {[{ key: "enableNatGateway", label: "NAT Gateway" }, { key: "enableDnsHostnames", label: "DNS Hostnames" }, { key: "enableFlowLogs", label: "VPC Flow Logs" }].map(opt => (
                <label key={opt.key} className={styles.toggle}><input type="checkbox" checked={(form as any)[opt.key]} onChange={e => setForm({ ...form, [opt.key]: e.target.checked })} /><span className={styles.toggleSlider} /><span>{opt.label}</span></label>
              ))}
            </div>
          </div>
          <button type="submit" className={styles.deployBtn} disabled={status === "deploying" || accounts.length === 0}>
            {status === "deploying" ? <><Loader2 size={18} className={styles.spin} /> Creating...</> : "🌐 Create VPC"}
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
