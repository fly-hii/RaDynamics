"use client";

import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { Mail, Lock, User, ArrowRight, ArrowLeft, Shield, CheckCircle, Eye, EyeOff, CloudIcon } from "lucide-react";
import { useRouter } from "next/navigation";
import Link from "next/link";
import Image from "next/image";
import styles from "./page.module.css";
import { useAuth } from "@/contexts/AuthContext";
import axios from "axios";

export default function SignupPage() {
  const [step, setStep] = useState(1); // 1: Details, 2: OTP
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [otp, setOtp] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const router = useRouter();
  const { login } = useAuth();

  const handleSignup = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    if (password !== confirmPassword) {
      setError("Passwords do not match.");
      return;
    }
    if (password.length < 8) {
      setError("Password must be at least 8 characters.");
      return;
    }
    setLoading(true);
    try {
      const resp = await axios.post("/api/auth/signup", { name, email, password });
      if (resp.data.success) {
        setStep(2);
      }
    } catch (err: any) {
      setError(err.response?.data?.error || "Signup failed. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  const handleVerify = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      const resp = await axios.post("/api/auth/signup-verify", { email, otp });
      if (resp.data.success) {
        login(resp.data.user, resp.data.token);
        router.push("/dashboard");
      }
    } catch (err: any) {
      setError(err.response?.data?.error || "Verification failed.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className={styles.container}>
      <div className={styles.bg}>
        <div className={styles.glow1} />
        <div className={styles.glow2} />
        <div className={styles.grid} />
      </div>

      <div className={styles.card}>
        <Link href="/" className={styles.homeLink}>
          <ArrowLeft size={16} /> Back to Home
        </Link>

        {/* Logo */}
        <Link href="/" className={styles.logoArea}>
          <Image 
            src="/logo.png" 
            alt="RayDynamics" 
            width={220} 
            height={54} 
            priority
          />
        </Link>

        {/* Step Indicator */}
        <div className={styles.steps}>
          <div className={`${styles.step} ${step >= 1 ? styles.stepDone : ""}`}>
            {step > 1 ? <CheckCircle size={16} /> : <span>1</span>}
            <span>Create Account</span>
          </div>
          <div className={styles.stepLine} />
          <div className={`${styles.step} ${step >= 2 ? styles.stepDone : ""}`}>
            <span>2</span>
            <span>Verify Email</span>
          </div>
        </div>

        <AnimatePresence mode="wait">
          {step === 1 ? (
            <motion.form
              key="step1"
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 20 }}
              onSubmit={handleSignup}
              className={styles.form}
            >
              <h2>Create your account</h2>
              <p className={styles.subtitle}>Start automating your cloud infrastructure today</p>

              <div className={styles.inputGroup}>
                <label>Full Name</label>
                <div className={styles.inputWrap}>
                  <User size={18} />
                  <input
                    type="text"
                    placeholder="John Doe"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    required
                  />
                </div>
              </div>

              <div className={styles.inputGroup}>
                <label>Business Email</label>
                <div className={styles.inputWrap}>
                  <Mail size={18} />
                  <input
                    type="email"
                    placeholder="john@company.com"
                    value={email}
                    onChange={(e) => setEmail(e.target.value)}
                    required
                  />
                </div>
              </div>

              <div className={styles.inputRow}>
                <div className={styles.inputGroup}>
                  <label>Password</label>
                  <div className={styles.inputWrap}>
                    <Lock size={18} />
                    <input
                      type={showPassword ? "text" : "password"}
                      placeholder="Min 8 characters"
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      required
                    />
                    <button type="button" onClick={() => setShowPassword(!showPassword)} className={styles.eyeBtn}>
                      {showPassword ? <EyeOff size={16} /> : <Eye size={16} />}
                    </button>
                  </div>
                </div>
                <div className={styles.inputGroup}>
                  <label>Confirm Password</label>
                  <div className={styles.inputWrap}>
                    <Lock size={18} />
                    <input
                      type="password"
                      placeholder="Repeat password"
                      value={confirmPassword}
                      onChange={(e) => setConfirmPassword(e.target.value)}
                      required
                    />
                  </div>
                </div>
              </div>

              {error && <p className={styles.error}>{error}</p>}

              <button type="submit" disabled={loading} className={styles.submitBtn}>
                {loading ? "Creating account..." : (<>Continue <ArrowRight size={18} /></>)}
              </button>

              <p className={styles.switchLink}>
                Already have an account? <Link href="/login">Sign in</Link>
              </p>
            </motion.form>
          ) : (
            <motion.form
              key="step2"
              initial={{ opacity: 0, x: 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -20 }}
              onSubmit={handleVerify}
              className={styles.form}
            >
              <div className={styles.otpHeader}>
                <div className={styles.otpIcon}><Shield size={32} /></div>
                <h2>Verify your email</h2>
                <p>We sent a 6-digit code to <strong>{email}</strong></p>
              </div>

              <div className={styles.inputGroup}>
                <label>Verification Code</label>
                <div className={styles.inputWrap}>
                  <input
                    type="text"
                    placeholder="000000"
                    maxLength={6}
                    value={otp}
                    onChange={(e) => setOtp(e.target.value.replace(/\D/g, ""))}
                    required
                    className={styles.otpInput}
                  />
                </div>
              </div>

              {error && <p className={styles.error}>{error}</p>}

              <button type="submit" disabled={loading} className={styles.submitBtn}>
                {loading ? "Verifying..." : "Complete Setup"}
              </button>
              <button type="button" className={styles.backBtn} onClick={() => setStep(1)}>
                ← Back
              </button>
            </motion.form>
          )}
        </AnimatePresence>

        <div className={styles.trust}>
          <Shield size={14} /> Enterprise-grade security. SOC2 compliant.
        </div>
      </div>
    </div>
  );
}
