"use client";

import React, { useEffect, useState } from "react";
import { 
  Server, 
  ArrowLeft, 
  Loader2, 
  CheckCircle, 
  AlertCircle, 
  Terminal,
  Zap,
  Github,
  Box,
  Globe,
  Plus,
  Rocket,
  PlusCircle,
  Database,
  Cloud,
  Layers,
  Settings,
  Shield
} from "lucide-react";
import { useRouter } from "next/navigation";
import styles from "./page.module.css";
import axios from "axios";
import { useAuth } from "@/contexts/AuthContext";
import { motion, AnimatePresence } from "framer-motion";

export default function DeployApplication() {
  const { user } = useAuth() as any;
  const router = useRouter();
  const [loading, setLoading] = useState(false);
  const [awsAccounts, setAwsAccounts] = useState<any[]>([]);
  const [ec2Instances, setEc2Instances] = useState<any[]>([]);
  const [loadingInstances, setLoadingInstances] = useState(false);
  
  const [formData, setFormData] = useState({
    name: "",
    deploymentMethod: "github",
    deploymentTarget: "ecs",
    awsAccountId: "",
    region: "us-east-1",
    ec2InstanceId: "",
    githubRepoUrl: "",
    githubBranch: "main",
    githubToken: "",
    appType: "auto",
    buildCommand: "",
    startCommand: "",
    dockerImage: "",
    dockerTag: "latest",
    port: 3000,
    cpu: "512",
    memory: "1024",
    environmentVariables: ""
  });

  const fetchAccounts = async () => {
    try {
      const resp = await axios.get("/api/aws/accounts");
      setAwsAccounts(resp.data.accounts || []);
      if (resp.data.accounts?.length > 0) {
        setFormData(prev => ({ ...prev, awsAccountId: resp.data.accounts[0]._id }));
      }
    } catch (err) {
      console.error("Failed to fetch accounts:", err);
    }
  };

  useEffect(() => {
    fetchAccounts();
  }, []);

  const handleDeploy = async () => {
    if (!formData.name) return alert("Application name is required");
    setLoading(true);
    try {
      const envVars: any = {};
      if (formData.environmentVariables) {
        formData.environmentVariables.split("\n").forEach(line => {
          const [k, v] = line.split("=");
          if (k && v) envVars[k.trim()] = v.trim();
        });
      }

      const payload = {
        name: formData.name,
        deploymentMethod: formData.deploymentMethod,
        deploymentTarget: formData.deploymentTarget,
        awsAccountId: formData.awsAccountId,
        runtime: {
          port: formData.port,
          cpu: formData.cpu,
          memory: formData.memory,
          environmentVariables: envVars
        },
        github: formData.deploymentMethod === "github" ? {
          repoUrl: formData.githubRepoUrl,
          branch: formData.githubBranch,
          token: formData.githubToken,
          appType: formData.appType,
          buildCommand: formData.buildCommand,
          startCommand: formData.startCommand
        } : undefined,
        docker: formData.deploymentMethod === "docker" ? {
          image: formData.dockerImage,
          tag: formData.dockerTag,
          registry: "dockerhub"
        } : undefined,
        ec2InstanceId: formData.deploymentTarget === "ec2" ? formData.ec2InstanceId : undefined
      };

      await axios.post("/api/applications", payload);
      alert("Deployment logic migrated. Waiting for implementation of deployment worker.");
      router.push("/dashboard/deployments");
    } catch (err: any) {
      alert("Failed to deploy: " + (err.response?.data?.error || err.message));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={styles.container}>
      <header className={styles.header}>
        <button className={styles.backBtn} onClick={() => router.back()}>
          <ArrowLeft size={20} />
        </button>
        <div className={styles.titleSection}>
          <h1>App Deployment</h1>
          <p>Deploy containers or source code to AWS Fargate or EC2.</p>
        </div>
      </header>

      <div className={styles.formGrid}>
        <div className={styles.mainContent}>
          <div className={styles.card}>
            <h2><Layers size={22} color="#0062ff" /> General Information</h2>
            <div className={styles.inputGroup}>
              <label>Application Name</label>
              <input 
                type="text" 
                placeholder="my-production-app" 
                className={styles.inputField}
                value={formData.name}
                onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              />
              <p className={styles.subText}>Use unique name for ECR and ECS services.</p>
            </div>
            
            <div className={styles.inputGroup}>
                <label>Deployment Method</label>
                <div className={styles.toggleGroup}>
                    <button 
                        className={`${styles.toggleBtn} ${formData.deploymentMethod === 'github' ? styles.active : ''}`}
                        onClick={() => setFormData({ ...formData, deploymentMethod: 'github' })}
                    >
                        <Github size={18} /> GitHub
                    </button>
                    <button 
                        className={`${styles.toggleBtn} ${formData.deploymentMethod === 'docker' ? styles.active : ''}`}
                        onClick={() => setFormData({ ...formData, deploymentMethod: 'docker' })}
                    >
                        <Box size={18} /> Docker
                    </button>
                </div>
            </div>
          </div>

          <AnimatePresence mode="wait">
            {formData.deploymentMethod === "github" ? (
              <motion.div 
                key="github"
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 10 }}
                className={styles.card}
              >
                <h2><Github size={22} color="#333" /> Source Configuration</h2>
                <div className={styles.inputGroup}>
                  <label>Repository URL</label>
                  <input 
                    type="text" 
                    placeholder="https://github.com/org/repo" 
                    className={styles.inputField}
                    value={formData.githubRepoUrl}
                    onChange={(e) => setFormData({ ...formData, githubRepoUrl: e.target.value })}
                  />
                </div>
                <div className={styles.fieldsGrid}>
                    <div className={styles.inputGroup}>
                        <label>Branch</label>
                        <input 
                            type="text" 
                            className={styles.inputField}
                            value={formData.githubBranch}
                            onChange={(e) => setFormData({ ...formData, githubBranch: e.target.value })}
                        />
                    </div>
                    <div className={styles.inputGroup}>
                        <label>App Type</label>
                        <select 
                            className={styles.selectField}
                            value={formData.appType}
                            onChange={(e) => setFormData({ ...formData, appType: e.target.value })}
                        >
                            <option value="auto">Auto-detect</option>
                            <option value="nodejs">Node.js</option>
                            <option value="react">React</option>
                            <option value="nextjs">Next.js</option>
                            <option value="python">Python</option>
                        </select>
                    </div>
                </div>
                <div className={styles.inputGroup}>
                    <label>Start Command</label>
                    <input 
                        type="text" 
                        placeholder="npm run start" 
                        className={styles.inputField}
                        value={formData.startCommand}
                        onChange={(e) => setFormData({ ...formData, startCommand: e.target.value })}
                    />
                </div>
              </motion.div>
            ) : (
                <motion.div 
                key="docker"
                initial={{ opacity: 0, x: -10 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 10 }}
                className={styles.card}
              >
                <h2><Box size={22} color="#2496ed" /> Docker Configuration</h2>
                <div className={styles.inputGroup}>
                  <label>Image Name</label>
                  <input 
                    type="text" 
                    placeholder="nginx or my-org/my-image" 
                    className={styles.inputField}
                    value={formData.dockerImage}
                    onChange={(e) => setFormData({ ...formData, dockerImage: e.target.value })}
                  />
                </div>
                <div className={styles.inputGroup}>
                  <label>Tag</label>
                  <input 
                    type="text" 
                    className={styles.inputField}
                    value={formData.dockerTag}
                    onChange={(e) => setFormData({ ...formData, dockerTag: e.target.value })}
                  />
                </div>
              </motion.div>
            )}
          </AnimatePresence>

          <div className={styles.card}>
            <h2><Settings size={22} color="#0062ff" /> Infrastructure & Runtime</h2>
            <div className={styles.inputGroup}>
                <label>AWS Account</label>
                <select 
                    className={styles.selectField}
                    value={formData.awsAccountId}
                    onChange={(e) => setFormData({ ...formData, awsAccountId: e.target.value })}
                >
                    {awsAccounts.map(acc => (
                        <option key={acc._id} value={acc._id}>{acc.accountName} ({acc.region})</option>
                    ))}
                </select>
            </div>
            
            <div className={styles.inputGroup}>
                <label>Deployment Target</label>
                <div className={styles.toggleGroup}>
                    <button 
                        className={`${styles.toggleBtn} ${formData.deploymentTarget === 'ecs' ? styles.active : ''}`}
                        onClick={() => setFormData({ ...formData, deploymentTarget: 'ecs' })}
                    >
                        <Cloud size={18} /> ECS Fargate
                    </button>
                    <button 
                        className={`${styles.toggleBtn} ${formData.deploymentTarget === 'ec2' ? styles.active : ''}`}
                        onClick={() => setFormData({ ...formData, deploymentTarget: 'ec2' })}
                    >
                        <Server size={18} /> EC2 Instance
                    </button>
                </div>
            </div>

            {formData.deploymentTarget === "ec2" && (
                <div className={styles.inputGroup}>
                    <label>EC2 Instance ID</label>
                    <input 
                        type="text" 
                        placeholder="i-0abcdef12345" 
                        className={styles.inputField}
                        value={formData.ec2InstanceId}
                        onChange={(e) => setFormData({ ...formData, ec2InstanceId: e.target.value })}
                    />
                </div>
            )}

            <div className={styles.fieldsGrid} style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '16px' }}>
                <div className={styles.inputGroup}>
                    <label>Port</label>
                    <input 
                        type="number" 
                        className={styles.inputField}
                        value={formData.port}
                        onChange={(e) => setFormData({ ...formData, port: parseInt(e.target.value) })}
                    />
                </div>
                <div className={styles.inputGroup}>
                    <label>CPU (Units)</label>
                    <select 
                        className={styles.selectField}
                        value={formData.cpu}
                        onChange={(e) => setFormData({ ...formData, cpu: e.target.value })}
                    >
                        <option value="256">256 (0.25 vCPU)</option>
                        <option value="512">512 (0.5 vCPU)</option>
                        <option value="1024">1024 (1 vCPU)</option>
                    </select>
                </div>
                <div className={styles.inputGroup}>
                    <label>Memory (MB)</label>
                    <select 
                        className={styles.selectField}
                        value={formData.memory}
                        onChange={(e) => setFormData({ ...formData, memory: e.target.value })}
                    >
                        <option value="512">512 MB</option>
                        <option value="1024">1024 MB</option>
                        <option value="2048">2048 MB</option>
                    </select>
                </div>
            </div>
          </div>
        </div>

        <div className={styles.sidebar}>
          <div className={styles.card + " " + styles.summaryCard}>
            <h3 className={styles.summaryTitle}>Deployment Summary</h3>
            
            <div className={styles.summaryItem}>
                <span className={styles.summaryLabel}>Platform</span>
                <span className={styles.summaryValue}>AWS Cloud</span>
            </div>
            <div className={styles.summaryItem}>
                <span className={styles.summaryLabel}>Target</span>
                <span className={styles.summaryValue}>{formData.deploymentTarget.toUpperCase()}</span>
            </div>
            <div className={styles.summaryItem}>
                <span className={styles.summaryLabel}>Optimization</span>
                <span className={styles.summaryValue}>Standard</span>
            </div>

            <div className={styles.featuresGrid}>
                <div className={styles.feature}><Shield size={14} /> HTTPS/SSL</div>
                <div className={styles.feature}><Zap size={14} /> Auto-scale</div>
            </div>

            <button 
                className={styles.deployBtn} 
                onClick={handleDeploy}
                disabled={loading || !formData.name}
            >
              {loading ? <Loader2 className={styles.spin} /> : <Rocket size={20} />}
              {loading ? "Initializing..." : "Deploy Application"}
            </button>
            <p className={styles.subText} style={{ textAlign: 'center', marginTop: '16px' }}>
                Estimated warm-up time: 2-5 minutes.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
