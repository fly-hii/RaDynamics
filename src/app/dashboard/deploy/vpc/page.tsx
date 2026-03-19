"use client";

import React, { useState } from "react";
import { motion } from "framer-motion";
import { 
  Network, 
  Globe, 
  Shield, 
  Zap, 
  Plus, 
  Trash2, 
  CheckCircle2,
  AlertCircle,
  Loader2
} from "lucide-react";
import styles from "./page.module.css";
import axios from "axios";
import { useRouter } from "next/navigation";

export default function DeployVPC() {
  const [formData, setFormData] = useState({
    vpcName: "RayDynamics-VPC",
    region: "us-east-1",
    cidrBlock: "10.0.0.0/16",
    resourcesMode: "vpc-and-more",
    createInternetGateway: true,
    createPublicSubnet: true,
    publicSubnetCidr: "10.0.1.0/24",
    awsAccountId: "" // Needs to be populated from accounts list
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
      const resp = await axios.post("/api/deploy/vpc", formData);
      if (resp.data.success) {
        setResult(resp.data.data);
      }
    } catch (err: any) {
      setError(err.response?.data?.error || "VPC deployment failed.");
    } finally {
      setDeploying(false);
    }
  };

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <div className={styles.titleArea}>
           <Network size={32} className={styles.titleIcon} />
           <div>
              <h1>Deploy VPC</h1>
              <p>Provision isolated virtual networks with advanced routing.</p>
           </div>
        </div>
      </div>

      <div className={styles.grid}>
         <div className={styles.formSection}>
            <form onSubmit={handleSubmit} className={styles.form}>
               <div className={styles.section}>
                  <h3>Basic Configuration</h3>
                  <div className={styles.inputRow}>
                     <div className={styles.inputGroup}>
                        <label>VPC Name</label>
                        <input 
                           type="text" 
                           value={formData.vpcName}
                           onChange={(e) => setFormData({...formData, vpcName: e.target.value})}
                        />
                     </div>
                     <div className={styles.inputGroup}>
                        <label>Region</label>
                        <select 
                           value={formData.region}
                           onChange={(e) => setFormData({...formData, region: e.target.value})}
                        >
                           <option value="us-east-1">US East (N. Virginia)</option>
                           <option value="us-west-2">US West (Oregon)</option>
                           <option value="ap-south-1">Asia Pacific (Mumbai)</option>
                           <option value="eu-central-1">Europe (Frankfurt)</option>
                        </select>
                     </div>
                  </div>
               </div>

               <div className={styles.section}>
                  <h3>Network Settings</h3>
                  <div className={styles.inputGroup}>
                     <label>IPv4 CIDR Block</label>
                     <input 
                        type="text" 
                        value={formData.cidrBlock}
                        onChange={(e) => setFormData({...formData, cidrBlock: e.target.value})}
                     />
                  </div>
                  
                  <div className={styles.radioGroup}>
                     <label className={styles.radio}>
                        <input 
                           type="radio" 
                           checked={formData.resourcesMode === 'vpc-only'}
                           onChange={() => setFormData({...formData, resourcesMode: 'vpc-only'})}
                        />
                        <span>VPC Only</span>
                     </label>
                     <label className={styles.radio}>
                        <input 
                           type="radio" 
                           checked={formData.resourcesMode === 'vpc-and-more'}
                           onChange={() => setFormData({...formData, resourcesMode: 'vpc-and-more'})}
                        />
                        <span>VPC and More (IGW, Subnets)</span>
                     </label>
                  </div>
               </div>

               <div className={styles.section}>
                  <h3>AWS Target Account</h3>
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

               <button type="submit" className={styles.deployBtn} disabled={deploying || accounts.length === 0}>
                  {deploying ? (
                     <><Loader2 className={styles.spin} size={20} /> Deploying VPC...</>
                  ) : (
                     <><Zap size={20} /> Provision Infrastructure</>
                  )}
               </button>
            </form>
         </div>

         <div className={styles.previewSection}>
            <div className={styles.previewCard}>
               <h3>Architecture Preview</h3>
               <div className={styles.visualizer}>
                  <div className={styles.vpcBox}>
                     <span className={styles.label}>VPC: {formData.vpcName}</span>
                     {formData.resourcesMode === 'vpc-and-more' && (
                        <div className={styles.subGrid}>
                           {formData.createInternetGateway && <div className={styles.igwBox}>IGW</div>}
                           {formData.createPublicSubnet && <div className={styles.subnetBox}>Public Subnet</div>}
                        </div>
                     )}
                  </div>
               </div>
               
               {result && (
                  <motion.div 
                     initial={{ opacity: 0, scale: 0.95 }}
                     animate={{ opacity: 1, scale: 1 }}
                     className={styles.successBox}
                  >
                     <CheckCircle2 size={32} />
                     <h4>Deployment Success</h4>
                     <p>VPC ID: <strong>{result.vpcId}</strong></p>
                     <button onClick={() => router.push('/dashboard/resources')}>View Resources</button>
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
