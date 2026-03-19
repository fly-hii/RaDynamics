"use client";

import React, { useState, useEffect, useRef } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { 
  CloudIcon, 
  Terminal, 
  Server, 
  ShieldCheck, 
  Box, 
  Zap, 
  LayoutDashboard, 
  ArrowRight,
  Menu,
  X,
  Plus,
  Globe,
  Database,
  Layers,
  Cpu,
  Shield,
  Activity,
  UserCheck,
  CreditCard,
  Briefcase,
  Users,
  HardDrive,
  Network,
  Lock,
  Workflow,
  Search,
  MessageSquare,
  BarChart,
  Play,
  Monitor,
  Mail,
  Send,
  Building
} from "lucide-react";
import styles from "./page.module.css";
import Link from "next/link";
import Image from "next/image";
import { useRouter } from "next/navigation";

/* Navbar Component */
const Navbar = () => {
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenu, setMobileMenu] = useState(false);
  const router = useRouter();

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 20);
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <nav className={`${styles.nav} ${scrolled ? styles.scrolled : ""}`}>
      <div className={styles.navContainer}>
        <Link href="/" className={styles.logo}>
          <Image 
            src="/logo.png" 
            alt="RayDynamics" 
            width={180} 
            height={44} 
            className={styles.logoImg}
            priority
          />
        </Link>
        <div className={styles.desktopNav}>
          <a href="#features" className={styles.navLink}>Features</a>
          <a href="#tour" className={styles.navLink}>Product Tour</a>
          <a href="#services" className={styles.navLink}>Services</a>
          <a href="#contact" className={styles.navLink}>Contact</a>
          <button onClick={() => router.push('/login')} className={styles.loginBtn}>Login</button>
          <button onClick={() => router.push('/signup')} className={styles.ctaBtn}>Get Started</button>
        </div>
        <div className={styles.mobileToggle} onClick={() => setMobileMenu(!mobileMenu)}>
          {mobileMenu ? <X size={24} /> : <Menu size={24} />}
        </div>
      </div>
      <AnimatePresence>
        {mobileMenu && (
          <motion.div 
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className={styles.mobileMenu}
          >
            <a href="#features" onClick={() => setMobileMenu(false)} className={styles.mobileNavLink}>Features</a>
            <a href="#services" onClick={() => setMobileMenu(false)} className={styles.mobileNavLink}>Services</a>
            <a href="#contact" onClick={() => setMobileMenu(false)} className={styles.mobileNavLink}>Contact</a>
            <button onClick={() => router.push('/login')} className={styles.mobileLogin}>Login</button>
            <button onClick={() => router.push('/signup')} className={styles.mobileCta}>Get Started</button>
          </motion.div>
        )}
      </AnimatePresence>
    </nav>
  );
};

/* Feature Card Component */
const FeatureCard = ({ icon: Icon, title, description, delay = 0 }: any) => {
  return (
    <motion.div 
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      transition={{ duration: 0.5, delay }}
      className={styles.featureCard}
    >
      <div className={styles.featureIcon}>
        <Icon size={24} color="#0062ff" />
      </div>
      <h3>{title}</h3>
      <p>{description}</p>
    </motion.div>
  );
};

/* Bento Grid Service Card */
const BentoService = ({ icon: Icon, name, desc, color, tag, className }: any) => (
  <motion.div 
    initial={{ opacity: 0, scale: 0.95 }}
    whileInView={{ opacity: 1, scale: 1 }}
    viewport={{ once: true }}
    whileHover={{ y: -5, borderColor: color }}
    className={`${styles.bentoCard} ${className}`}
  >
    <div className={styles.bentoIcon} style={{ background: `${color}15`, color: color }}>
       <Icon size={24} />
    </div>
    <div className={styles.bentoMeta}>
       <span className={styles.bentoTag}>{tag}</span>
       <h4>{name}</h4>
       <p>{desc}</p>
    </div>
  </motion.div>
);

export default function LandingPage() {
  const router = useRouter();

  const techStack = [
    "AWS Ecosystem", "HashiCorp Terraform", "Docker", "Kubernetes", "Next.js 16+", 
    "TypeScript", "OAuth 2.0", "CloudWatch", "GitHub Actions", "GitOps", 
    "Zero-Trust Architecture", "AES-256 Storage"
  ];

  // Video State
  const videoRef = useRef<HTMLVideoElement>(null);
  const [isPlaying, setIsPlaying] = useState(true);
  const [isMuted, setIsMuted] = useState(true);
  const [volume, setVolume] = useState(0.7);

  const toggleMute = (e: React.MouseEvent) => {
    e.stopPropagation();
    if (videoRef.current) {
      if (isMuted) {
        videoRef.current.muted = false;
        videoRef.current.volume = volume;
      } else {
        videoRef.current.muted = true;
      }
      setIsMuted(!isMuted);
    }
  };

  const handleVolume = (e: React.ChangeEvent<HTMLInputElement>) => {
    e.stopPropagation();
    const val = parseFloat(e.target.value);
    setVolume(val);
    if (videoRef.current) {
      videoRef.current.volume = val;
      videoRef.current.muted = val === 0;
      setIsMuted(val === 0);
    }
  };

  // Form State
  const [formData, setFormData] = useState({ name: "", email: "", org: "", message: "" });
  const [formStatus, setFormStatus] = useState<null | 'sending' | 'success'>(null);

  // Hero interactive card state
  const [activeCard, setActiveCard] = useState(0);
  const [deployCount, setDeployCount] = useState(1247);
  const [cpuVal, setCpuVal] = useState(34);
  const [logs, setLogs] = useState([
    { text: "ec2-prod-01 → Running", ok: true },
    { text: "s3-backup synced", ok: true },
    { text: "rds-cluster: healthy", ok: true },
  ]);

  // Tick metrics every 2s to simulate live dashboard
  useEffect(() => {
    const t = setInterval(() => {
      setDeployCount(c => c + Math.floor(Math.random() * 3));
      setCpuVal(Math.floor(24 + Math.random() * 32));
      const services = ["ecs-cluster", "vpc-gateway", "lambda-fn", "eks-node", "alb-prod"];
      const newLine = { text: `${services[Math.floor(Math.random()*services.length)]} → OK`, ok: true };
      setLogs(prev => [newLine, ...prev.slice(0, 2)]);
    }, 2000);
    return () => clearInterval(t);
  }, []);

  const scrollToVideo = () => {
    document.getElementById('tour')?.scrollIntoView({ behavior: 'smooth' });
  };

  const togglePlay = () => {
    if (videoRef.current) {
      if (isPlaying) videoRef.current.pause();
      else videoRef.current.play();
      setIsPlaying(!isPlaying);
    }
  };

  const handleContactSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setFormStatus('sending');
    setTimeout(() => {
        setFormStatus('success');
        setFormData({ name: "", email: "", org: "", message: "" });
    }, 1500);
  };

  useEffect(() => {
    if (videoRef.current) {
        if (isPlaying) videoRef.current.play().catch(() => setIsPlaying(false));
        else videoRef.current.pause();
    }
  }, [isPlaying]);

  return (
    <div className={styles.page}>
      <Navbar />
      
      {/* Hero Section */}
      <section className={styles.hero}>
        <div className={styles.heroBackground}>
          <div className={styles.glow1}></div>
          <div className={styles.glow2}></div>
          <div className={styles.gridOverlay}></div>
        </div>

        <div className={styles.heroContent}>
          <motion.div 
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
            className={styles.heroHeader}
          >
            <div className={styles.badge}>Cloud Infrastructure Management</div>
            <h1>The <span className={styles.highlight}>Intelligence</span> Layer for Multi-Cloud</h1>
            <p className={styles.heroDescription}>
              Experience seamless AWS resource orchestration. From VPC networking to EKS clusters, 
              deploy production-grade environments with click-button ease and Terraform precision.
            </p>
            <div className={styles.heroActions}>
              <button 
                onClick={() => router.push('/dashboard')} 
                className={styles.primaryAction}
              >
                Launch Platform <ArrowRight size={20} />
              </button>
              <button onClick={scrollToVideo} className={styles.secondaryAction}>
                <Play size={18} fill="currentColor" /> Watch Demo
              </button>
            </div>

            {/* Stats Row */}
            <div className={styles.heroStats}>
               <div className={styles.heroStatItem}>
                 <span className={styles.statVal}>99.9%</span>
                 <span className={styles.statLab}>Success Rate</span>
               </div>
               <div className={styles.heroStatItem}>
                 <span className={styles.statVal}>Instant</span>
                 <span className={styles.statLab}>Provisioning</span>
               </div>
               <div className={styles.heroStatItem}>
                 <span className={styles.statVal}>Bank-Grade</span>
                 <span className={styles.statLab}>Security</span>
               </div>
            </div>
          </motion.div>

          {/* Interactive Animated Dashboard Preview */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            transition={{ duration: 1, delay: 0.2 }}
            className={styles.heroPreview}
            onClick={scrollToVideo}
          >
            <div className={styles.previewFrame}>
              {/* Browser chrome */}
              <div className={styles.frameHeader}>
                <div className={styles.dots}>
                  <span style={{ background: '#ef4444' }}></span>
                  <span style={{ background: '#f59e0b' }}></span>
                  <span style={{ background: '#10b981' }}></span>
                </div>
                <div className={styles.searchBar}>raydynamics.com/dashboard</div>
                <div className={styles.liveIndicator}><span></span>LIVE</div>
              </div>

              <div className={styles.frameBody}>
                {/* Sidebar */}
                <div className={styles.sideBar}>
                  {[LayoutDashboard, Server, Box, Zap, ShieldCheck].map((Icon, i) => (
                    <div
                      key={i}
                      className={`${styles.sideIcon} ${activeCard === i ? styles.sideIconActive : ''}`}
                      onClick={(e) => { e.stopPropagation(); setActiveCard(i); }}
                    >
                      <Icon size={16} />
                    </div>
                  ))}
                </div>

                {/* Main area */}
                <div className={styles.mainContentFull}>
                  {/* Stat cards */}
                  <div className={styles.previewStats}>
                    <motion.div
                      key={deployCount}
                      initial={{ scale: 1.05, color: '#10b981' }}
                      animate={{ scale: 1, color: '#fff' }}
                      transition={{ duration: 0.4 }}
                      className={styles.pStat}
                    >
                      <span className={styles.pStatLabel}>Deployments</span>
                      <span className={styles.pStatVal}>{deployCount.toLocaleString()}</span>
                    </motion.div>
                    <motion.div
                      key={cpuVal}
                      initial={{ scale: 1.05 }}
                      animate={{ scale: 1 }}
                      transition={{ duration: 0.4 }}
                      className={styles.pStat}
                    >
                      <span className={styles.pStatLabel}>CPU Usage</span>
                      <span className={styles.pStatVal} style={{ color: cpuVal > 50 ? '#f59e0b' : '#10b981' }}>{cpuVal}%</span>
                    </motion.div>
                    <div className={styles.pStat}>
                      <span className={styles.pStatLabel}>Health</span>
                      <span className={styles.pStatVal} style={{ color: '#10b981' }}>Nominal</span>
                    </div>
                  </div>

                  {/* Animated chart */}
                  <div className={styles.previewChart}>
                    <svg width="100%" height="100%" viewBox="0 0 300 80" preserveAspectRatio="none">
                      <defs>
                        <linearGradient id="chartGrad" x1="0" y1="0" x2="0" y2="1">
                          <stop offset="0%" stopColor="#0062ff" stopOpacity="0.3" />
                          <stop offset="100%" stopColor="#0062ff" stopOpacity="0" />
                        </linearGradient>
                      </defs>
                      <motion.path
                        d="M0,60 Q30,40 60,50 T120,30 T180,45 T240,20 T300,35"
                        fill="none"
                        stroke="#0062ff"
                        strokeWidth="2"
                        initial={{ pathLength: 0 }}
                        animate={{ pathLength: 1 }}
                        transition={{ duration: 2, repeat: Infinity, repeatType: 'loop', ease: 'linear' }}
                      />
                      <motion.path
                        d="M0,60 Q30,40 60,50 T120,30 T180,45 T240,20 T300,35 V80 H0Z"
                        fill="url(#chartGrad)"
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        transition={{ duration: 1 }}
                      />
                    </svg>
                    <div className={styles.chartLabel}>Infrastructure Health — 24h</div>
                  </div>

                  {/* Live log feed */}
                  <div className={styles.previewLogFeed}>
                    <AnimatePresence mode="popLayout">
                      {logs.map((log, i) => (
                        <motion.div
                          key={log.text + i}
                          initial={{ opacity: 0, x: -10 }}
                          animate={{ opacity: 1, x: 0 }}
                          exit={{ opacity: 0 }}
                          transition={{ duration: 0.3 }}
                          className={styles.logLine}
                        >
                          <span className={styles.logDot} style={{ background: log.ok ? '#10b981' : '#ef4444' }}></span>
                          <span className={styles.logText}>{log.text}</span>
                        </motion.div>
                      ))}
                    </AnimatePresence>
                  </div>
                </div>
              </div>

              {/* Click to Watch Demo overlay hint */}
              <div className={styles.previewClickHint}>
                <Play size={14} fill="white" /> Click to watch full demo
              </div>
              <div className={styles.previewGlow}></div>
            </div>
          </motion.div>
        </div>
      </section>

      {/* Tech Marquee Section */}
      <section className={styles.techMarqueeSection}>
         <div className={styles.marqueeHeader}>Core Technologies Powered By RayDynamics</div>
         <div className={styles.marquee}>
            <div className={styles.marqueeContent}>
               {techStack.map((tech, i) => (
                  <div key={i} className={styles.techItem}>
                     <div className={styles.dot} /> {tech}
                  </div>
               ))}
               {techStack.map((tech, i) => (
                  <div key={`d2-${i}`} className={styles.techItem}>
                     <div className={styles.dot} /> {tech}
                  </div>
               ))}
            </div>
         </div>
      </section>

      {/* Product Video Tour Section */}
      <section id="tour" className={styles.videoTourSection}>
         <div className={styles.sectionHeader}>
            <div className={styles.preTitle}>Visual Tour</div>
            <h2>See the Intelligence in Action</h2>
            <p>Experience the seamless flow of infrastructure automation through our platform vision.</p>
         </div>
         
         <div className={styles.videoWrapper}>
            <div className={styles.videoReflection}></div>
            <div className={styles.videoFrame} onClick={togglePlay}>
               <video 
                 ref={videoRef}
                 className={styles.platformVideo} 
                 autoPlay 
                 muted
                 loop 
                 playsInline
               >
                  <source src="/videos/platform_tour.mp4" type="video/mp4" />
                  Your browser does not support the video tag.
               </video>
               <AnimatePresence>
                  {!isPlaying && (
                    <motion.div 
                      initial={{ opacity: 0, scale: 0.8 }}
                      animate={{ opacity: 1, scale: 1 }}
                      exit={{ opacity: 0, scale: 0.8 }}
                      className={styles.videoOverlay}
                    >
                        <div className={styles.playIcon}><Play size={40} fill="white" /></div>
                    </motion.div>
                  )}
               </AnimatePresence>
               <div className={styles.videoControls}>
                  <div className={styles.controlLeft}>
                    <div className={styles.controlTitle}>RayDynamics Platform Vision v2.0</div>
                    <div className={styles.controlStatus}>
                      {isPlaying ? "Now Playing" : "Paused"}
                    </div>
                  </div>
                  <div className={styles.controlRight} onClick={(e) => e.stopPropagation()}>
                    <input
                      type="range"
                      min={0}
                      max={1}
                      step={0.05}
                      value={isMuted ? 0 : volume}
                      onChange={handleVolume}
                      className={styles.volumeSlider}
                      title="Volume"
                    />
                    <button onClick={toggleMute} className={styles.muteBtn} title={isMuted ? "Unmute" : "Mute"}>
                      {isMuted ? (
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                          <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/>
                          <line x1="23" y1="9" x2="17" y2="15"/>
                          <line x1="17" y1="9" x2="23" y2="15"/>
                        </svg>
                      ) : (
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                          <polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/>
                          <path d="M19.07 4.93a10 10 0 0 1 0 14.14"/>
                          <path d="M15.54 8.46a5 5 0 0 1 0 7.07"/>
                        </svg>
                      )}
                    </button>
                  </div>
               </div>
            </div>
            <div className={styles.videoGlow}></div>
         </div>
      </section>

      {/* Bento Services Grid */}
      <section id="services" className={styles.servicesGridSection}>
         <div className={styles.sectionHeader}>
            <div className={styles.preTitle}>Comprehensive Fabric</div>
            <h2>Unified Cloud Services</h2>
            <p>Every critical AWS service, automated and secured through our high-performance control plane.</p>
         </div>
         
         <div className={styles.bentoGrid}>
            <BentoService 
               icon={Server} name="EC2 Clusters" tag="Compute" color="#0062ff" 
               desc="Elastic compute with automated auto-scaling and high availability architecture."
               className={styles.bentoLarge}
            />
            <BentoService 
               icon={Box} name="S3 Storage" tag="Data" color="#10b981" 
               desc="Scalable object storage with encryption and versioning enforced at source."
            />
            <BentoService 
               icon={Database} name="RDS Clusters" tag="Database" color="#f59e0b" 
               desc="Managed DBs with auto-backups and sub-millisecond multi-AZ replication."
            />
            <BentoService 
               icon={Lock} name="IAM Management" tag="Security" color="#ef4444" 
               desc="Zero-trust identity control with automated policy rotation and MFA."
               className={styles.bentoWide}
            />
            <BentoService 
               icon={Network} name="VPC Networking" tag="Fabric" color="#8b5cf6" 
               desc="Private network isolation with managed NAT gateways and route tables."
            />
            <BentoService 
               icon={Zap} name="Lambda Functions" tag="Serverless" color="#6366f1" 
               desc="Event-driven serverless deployments with sub-second execution logic."
            />
            <BentoService 
               icon={Layers} name="EKS Control Plane" tag="Containers" color="#ec4899" 
               desc="Production K8s clusters with managed node groups and Fargate profiles."
               className={styles.bentoWide}
            />
            <BentoService 
               icon={Globe} name="CloudFront CDN" tag="Edge" color="#14b8a6" 
               desc="Global Delivery with SSL termination and intelligent DDoS protection."
            />
            <BentoService 
               icon={Search} name="CloudWatch Ops" tag="Monitoring" color="#94a3b8" 
               desc="End-to-end observability with real-time dashboards and alerting."
            />
         </div>
      </section>

      {/* Contact Section */}
      <div className={styles.sectionDivider}>
        <div className={styles.dividerLine}></div>
        <div className={styles.dividerLabel}>
          <Mail size={16} /> Get in Touch
        </div>
        <div className={styles.dividerLine}></div>
      </div>
      <section id="contact" className={styles.contactSection}>
          <div className={styles.contactContainer}>
             <motion.div 
               initial={{ opacity: 0, x: -30 }}
               whileInView={{ opacity: 1, x: 0 }}
               transition={{ duration: 0.8 }}
               className={styles.contactInfo}
             >
                <div className={styles.preTitle}>Request Consultation</div>
                <h2>Talk to our Cloud Experts</h2>
                <p>Ready to automate your AWS infrastructure? Our team is available 24/7 for tailored enterprise solutions.</p>
                <div className={styles.contactIcons}>
                   <div className={styles.contactIconItem}>
                      <Mail color="#0062ff" size={24} />
                      <div>
                         <span>Email Us</span>
                         <strong>raydynamics@flyhii.in</strong>
                      </div>
                   </div>
                   <div className={styles.contactIconItem}>
                      <Globe color="#10b981" size={24} />
                      <div>
                         <span>Global Support</span>
                         <strong>Available in 20+ Regions</strong>
                      </div>
                   </div>
                </div>
             </motion.div>

             <motion.form 
                initial={{ opacity: 0, x: 30 }}
                whileInView={{ opacity: 1, x: 0 }}
                transition={{ duration: 0.8 }}
                onSubmit={handleContactSubmit}
                className={styles.contactForm}
             >
                <div className={styles.inputGroup}>
                   <label>Full Name</label>
                   <div className={styles.inputWrapper}>
                      <Users size={18} />
                      <input 
                        required 
                        type="text" 
                        placeholder="John Doe" 
                        value={formData.name}
                        onChange={(e) => setFormData({...formData, name: e.target.value})}
                      />
                   </div>
                </div>
                <div className={styles.inputRow}>
                    <div className={styles.inputGroup}>
                       <label>Business Email</label>
                       <div className={styles.inputWrapper}>
                          <Mail size={18} />
                          <input 
                            required 
                            type="email" 
                            placeholder="john@company.com" 
                            value={formData.email}
                            onChange={(e) => setFormData({...formData, email: e.target.value})}
                          />
                       </div>
                    </div>
                    <div className={styles.inputGroup}>
                       <label>Organization</label>
                       <div className={styles.inputWrapper}>
                          <Building size={18} />
                          <input 
                            required 
                            type="text" 
                            placeholder="Organization Name" 
                            value={formData.org}
                            onChange={(e) => setFormData({...formData, org: e.target.value})}
                          />
                       </div>
                    </div>
                </div>
                <div className={styles.inputGroup}>
                   <label>Message</label>
                   <div className={styles.inputWrapper} style={{ alignItems: 'flex-start' }}>
                      <MessageSquare size={18} style={{ marginTop: '12px' }} />
                      <textarea 
                        required 
                        rows={4} 
                        placeholder="Tell us about your infrastructure goals..."
                        value={formData.message}
                        onChange={(e) => setFormData({...formData, message: e.target.value})}
                      ></textarea>
                   </div>
                </div>
                <button type="submit" className={styles.submitBtn} disabled={formStatus === 'sending'}>
                   {formStatus === 'sending' ? (
                     "Transmitting..."
                   ) : formStatus === 'success' ? (
                     "Transmitted Substantially ✅"
                   ) : (
                     <>Send Request <Send size={18} /></>
                   )}
                </button>
             </motion.form>
          </div>
      </section>

      {/* Footer */}
      <footer className={styles.footer}>
        <div className={styles.footerContainer}>
          <div className={styles.footerBrand}>
            <Link href="/" className={styles.logoSmall}>
              <Image src="/logo.png" alt="RayDynamics" width={140} height={34} />
            </Link>
            <p>Advancing cloud operations with intelligent automation infrastructure.</p>
            <div className={styles.copy}>© 2026 RayDynamics. Developed by Advanced Systems.</div>
          </div>
          <div className={styles.footerLinks}>
            <div className={styles.linkCol}>
              <h4>Ecosystem</h4>
              <a href="#">Security Portal</a>
              <a href="#">API Gateway</a>
              <a href="#">Status Page</a>
            </div>
            <div className={styles.linkCol}>
              <h4>Corporate</h4>
              <p>Legal Privacy</p>
              <p>Terms of Operation</p>
              <p>Hiring</p>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
