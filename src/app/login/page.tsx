"use client";

import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Mail, Lock, ArrowRight, ArrowLeft, Shield, Command, Activity, Zap } from "lucide-react";
import { useRouter } from "next/navigation";
import Link from 'next/link';
import Image from 'next/image';
import styles from './page.module.css';
import { useAuth } from "@/contexts/AuthContext";
import axios from "axios";

export default function LoginPage() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [otp, setOtp] = useState("");
  const [step, setStep] = useState(1); // 1: Login, 2: OTP
  const [tempToken, setTempToken] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  
  const router = useRouter();
  const { login } = useAuth();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError("");
    
    try {
      const resp = await axios.post("/api/auth/login", { email, password });
      if (resp.data.success) {
        setTempToken(resp.data.tempToken);
        setStep(2);
      }
    } catch (err: any) {
      setError(err.response?.data?.error || "Login failed. Check your credentials.");
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOtp = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError("");

    try {
      const resp = await axios.post("/api/auth/verify-otp", { 
        email, 
        otp, 
        tempToken 
      });
      
      if (resp.data.success) {
        login(resp.data.user, resp.data.token);
        router.push("/dashboard");
      }
    } catch (err: any) {
      setError(err.response?.data?.error || "Verification failed. Invalid OTP.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={styles.container}>
      {/* Background elements */}
      <div className={styles.circuitBg} />
      <div className={styles.glow} />
      
      <div className={styles.loginCard}>
        <Link href="/" className={styles.homeLink}>
          <ArrowLeft size={16} /> Back to Home
        </Link>

        <Link href="/" className={styles.cardHeader}>
          <Image 
            src="/logo.png" 
            alt="RayDynamics" 
            width={220} 
            height={54} 
            className={styles.loginLogo}
            priority
          />
        </Link>

        <AnimatePresence mode="wait">
          {step === 1 ? (
            <motion.form 
              key="step1"
              initial={{ x: -20, opacity: 0 }}
              animate={{ x: 0, opacity: 1 }}
              exit={{ x: 20, opacity: 0 }}
              onSubmit={handleLogin} 
              className={styles.form}
            >
              <div className={styles.inputGroup}>
                <Mail className={styles.icon} size={20} />
                <input 
                  type="email" 
                  placeholder="Corporate Email" 
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required 
                />
              </div>
              <div className={styles.inputGroup}>
                <Lock className={styles.icon} size={20} />
                <input 
                  type="password" 
                  placeholder="Master Key" 
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required 
                />
              </div>

              {error && <p className={styles.error}>{error}</p>}

              <button type="submit" className={styles.submitBtn} disabled={loading}>
                {loading ? "Authenticating..." : (
                  <>Continue <ArrowRight size={20} /></>
                )}
              </button>
            </motion.form>
          ) : (
            <motion.form 
              key="step2"
              initial={{ x: 20, opacity: 0 }}
              animate={{ x: 0, opacity: 1 }}
              exit={{ x: -20, opacity: 0 }}
              onSubmit={handleVerifyOtp} 
              className={styles.form}
            >
              <div className={styles.otpInfo}>
                <Shield size={32} className={styles.shieldIcon} />
                <h2>MFA Verification</h2>
                <p>Enter the 6-digit code sent to <strong>{email}</strong></p>
              </div>
              
              <div className={styles.inputGroup}>
                <Activity className={styles.icon} size={20} />
                <input 
                  type="text" 
                  placeholder="000000" 
                  maxLength={6}
                  value={otp}
                  onChange={(e) => setOtp(e.target.value)}
                  required 
                  className={styles.otpInput}
                />
              </div>

              {error && <p className={styles.error}>{error}</p>}

              <button type="submit" className={styles.submitBtn} disabled={loading}>
                {loading ? "Verifying..." : "Access Dashboard"}
              </button>
              
              <button 
                type="button" 
                className={styles.backBtn}
                onClick={() => setStep(1)}
              >
                Back to credentials
              </button>
            </motion.form>
          )}
        </AnimatePresence>

        <div className={styles.footer}>
          <div className={styles.trustBadge}>
             <Shield size={14} /> SOC2 Type II Certified
          </div>
          <div className={styles.switchPage}>
             New to the platform? <Link href="/signup">Create account</Link>
          </div>
          <div className={styles.status}>
             <span className={styles.dot} /> All Systems Operational
          </div>
        </div>
      </div>

      <div className={styles.brandPanel}>
         <div className={styles.floatingFeatures}>
            <div className={styles.feature}>
               <Command size={24} />
               <div>
                  <h3>Unified Orchestration</h3>
                  <p>Manage multi-cloud resources from a single console.</p>
               </div>
            </div>
            <div className={styles.feature}>
               <Zap size={24} />
               <div>
                  <h3>Automated Provisioning</h3>
                  <p>Terraform-powered infrastructure as code.</p>
               </div>
            </div>
         </div>
      </div>
    </div>
  );
}
