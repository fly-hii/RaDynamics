"use client";

import React, { useState } from "react";
import { motion } from "framer-motion";
import { 
  Server, 
  Cpu, 
  Zap, 
  Trash2, 
  CheckCircle2,
  AlertCircle,
  Loader2,
  HardDrive,
  Key
} from "lucide-react";
import styles from "./page.module.css";
import axios from "axios";
import { useRouter } from "next/navigation";

export default function DeployEC2() {
  const [formData, setFormData] = useState({
    instance_name: "Web-Server-Primary",
    region: "us-east-1",
    instance_type: "t3.medium",
    ami_id: "ami-0c7217cdde317cfec", // Amazon Linux 2023
    key_name: "",
    root_volume_size: 20,
    root_volume_type: "gp3",
    awsAccountId: ""
  });

  const [accounts, setAccounts] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const [deploying, setDeploying] = useState(false);
  const [result, setResult] = useState<any>(null);
  const [error, setError] = useState("");
  
  const router = useRouter();

  React.useEffect(() => {
    const fetchAccounts = async () => {
      setLoading(true);
      try {
        const resp = await axios.get("/api/aws/accounts");
        setAccounts(resp.data.accounts);
        if (resp.data.accounts.length > 0) {
          setFormData(prev => ({ ...prev, awsAccountId: resp.data.accounts[0]._id }));
        }
      } catch (err) {
        setError("Failed to load AWS accounts.");
      } finally {
        setLoading(false);
      }
    };
    fetchAccounts();
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setDeploying(true);
    setResult(null);
    setError("");

    try {
      const resp = await axios.post("/api/deploy/ec2", formData);
      if (resp.data.success) {
        setResult(resp.data);
      }
    } catch (err: any) {
      setError(err.response?.data?.error || "EC2 deployment failed.");
    } finally {
      setDeploying(false);
    }
  };

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <div className={styles.titleArea}>
           <Server size={32} className={styles.titleIcon} />
           <div>
              <h1>Deploy EC2 Instance</h1>
              <p>Provision virtual servers with high-performance computing capabilities.</p>
           </div>
        </div>
      </div>

      <div className={styles.grid}>
         <div className={styles.formSection}>
            <form onSubmit={handleSubmit} className={styles.form}>
               <div className={styles.section}>
                  <h3>Instance Configuration</h3>
                  <div className={styles.inputRow}>
                     <div className={styles.inputGroup}>
                        <label>Instance Name</label>
                        <input 
                           type="text" 
                           value={formData.instance_name}
                           onChange={(e) => setFormData({...formData, instance_name: e.target.value})}
                        />
                     </div>
                     <div className={styles.inputGroup}>
                        <label>Instance Type</label>
                        <select 
                           value={formData.instance_type}
                           onChange={(e) => setFormData({...formData, instance_type: e.target.value})}
                        >
                           <option value="t2.micro">t2.micro (Free Tier)</option>
                           <option value="t3.small">t3.small (Standard)</option>
                           <option value="t3.medium">t3.medium (Recommended)</option>
                           <option value="m5.large">m5.large (Compute Optimized)</option>
                        </select>
                     </div>
                  </div>
               </div>

               <div className={styles.section}>
                  <h3>Target AWS Account</h3>
                  <div className={styles.inputGroup}>
                     <label>Select AWS Account</label>
                     <select 
                        value={formData.awsAccountId}
                        onChange={(e) => setFormData({...formData, awsAccountId: e.target.value})}
                        disabled={loading}
                     >
                        {accounts.map(acc => (
                           <option key={acc._id} value={acc._id}>{acc.accountName} ({acc.accountId})</option>
                        ))}
                        {accounts.length === 0 && <option value="">No accounts found</option>}
                     </select>
                  </div>
               </div>

               <div className={styles.section}>
                  <h3>Infrastructure Details</h3>
                  <div className={styles.inputRow}>
                     <div className={styles.inputGroup}>
                        <label>Region</label>
                        <select 
                           value={formData.region}
                           onChange={(e) => setFormData({...formData, region: e.target.value})}
                        >
                           <option value="us-east-1">US East (N. Virginia)</option>
                           <option value="us-west-2">US West (Oregon)</option>
                           <option value="ap-south-1">Asia Pacific (Mumbai)</option>
                        </select>
                     </div>
                     <div className={styles.inputGroup}>
                        <label>AMI ID</label>
                        <input 
                           type="text" 
                           value={formData.ami_id}
                           onChange={(e) => setFormData({...formData, ami_id: e.target.value})}
                        />
                     </div>
                  </div>
                  <div className={styles.inputGroup}>
                     <label>Key Pair Name</label>
                     <input 
                        type="text" 
                        placeholder="my-key-pair"
                        value={formData.key_name}
                        onChange={(e) => setFormData({...formData, key_name: e.target.value})}
                     />
                  </div>
               </div>

               <button type="submit" className={styles.deployBtn} disabled={deploying || accounts.length === 0}>
                  {deploying ? (
                     <><Loader2 className={styles.spin} size={20} /> Starting Deployment...</>
                  ) : (
                     <><Zap size={20} /> Launch Instance</>
                  )}
               </button>
            </form>
         </div>

         <div className={styles.previewSection}>
            <div className={styles.previewCard}>
               <h3>Instance Spec Preview</h3>
               <div className={styles.visualizer}>
                  <div className={styles.ec2Box}>
                     <Cpu size={48} className={styles.cpuIcon} />
                     <div className={styles.specBadge}>{formData.instance_type}</div>
                     <div className={styles.storageLine}>
                        <HardDrive size={16} /> {formData.root_volume_size}GB {formData.root_volume_type}
                     </div>
                     <div className={styles.keyBadge}>
                         <Key size={14} /> {formData.key_name || 'No Key'}
                     </div>
                  </div>
               </div>
               
               {result && (
                  <motion.div 
                     initial={{ opacity: 0, scale: 0.95 }}
                     animate={{ opacity: 1, scale: 1 }}
                     className={styles.successBox}
                  >
                     <CheckCircle2 size={32} />
                     <h4>EC2 Deployment Queued</h4>
                     <p>Deployment ID: <br/><strong>{result.deploymentId}</strong></p>
                     <button onClick={() => router.push('/dashboard/deployments')}>Monitor Status</button>
                  </motion.div>
               )}

               {error && (
                  <div className={styles.errorBox}>
                     <AlertCircle size={24} />
                     <p>{error}</p>
                  </div>
               )}
            </div>
         </div>
      </div>
    </div>
  );
}
