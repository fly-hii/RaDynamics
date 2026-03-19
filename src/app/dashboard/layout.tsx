"use client";

import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { 
  LayoutDashboard, 
  Box, 
  Zap, 
  Shield, 
  Settings, 
  LogOut, 
  Bell, 
  Search,
  User,
  Menu,
  X,
  Plus,
  Cloud,
  Activity,
  Key,
  Network,
  Package,
  ChevronRight
} from "lucide-react";
import Link from "next/link";
import Image from "next/image";
import { usePathname, useRouter } from "next/navigation";
import styles from "./dashboard.module.css";
import { useAuth } from "@/contexts/AuthContext";

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [searchOpen, setSearchOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState("");
  const pathname = usePathname();
  const router = useRouter();
  const { user, logout, isLoading } = useAuth();

  // Route Protection
  React.useEffect(() => {
    if (!isLoading && !user) {
      router.push('/login');
    }
  }, [user, isLoading, router]);

  // Shortcut key for search
  React.useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if ((e.metaKey || e.ctrlKey) && e.key === 'k') {
        e.preventDefault();
        setSearchOpen(true);
      }
    };
    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);

  if (isLoading || !user) {
    return <div className={styles.loading}>Initializing Control Plane...</div>;
  }

  const menuItems = [
    { name: "Overview", icon: LayoutDashboard, path: "/dashboard" },
    { name: "Services", icon: Cloud, path: "/dashboard/services" },
    { name: "Applications", icon: Package, path: "/dashboard/services/applications" },
    { name: "App Comms", icon: Network, path: "/dashboard/services/communication" },
    { name: "Deployments", icon: Zap, path: "/dashboard/deployments" },
    { name: "Resources", icon: Box, path: "/dashboard/resources" },
    { name: "Monitoring", icon: Activity, path: "/dashboard/monitoring" },
    { name: "Security", icon: Shield, path: "/dashboard/security" },
    { name: "Settings", icon: Settings, path: "/dashboard/settings" },
  ];

  const filteredSearchItems = menuItems.filter(item => 
    item.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className={styles.layout}>
      {/* Sidebar */}
      {sidebarOpen && (
        <div 
          className={styles.mobileOverlay} 
          onClick={() => setSidebarOpen(false)}
        />
      )}
      <aside className={`${styles.sidebar} ${sidebarOpen ? styles.sidebarOpen : styles.sidebarClosed}`}>
        <div className={styles.sidebarHeader}>
          <Link href="/dashboard" className={styles.logo}>
            <Image 
              src="/logo.png" 
              alt="RayDynamics" 
              width={sidebarOpen ? 160 : 32} 
              height={sidebarOpen ? 40 : 32} 
              style={{ objectFit: sidebarOpen ? 'contain' : 'cover', objectPosition: 'left' }}
            />
          </Link>
          <button 
            className={styles.toggleBtn}
            onClick={() => setSidebarOpen(!sidebarOpen)}
          >
            {sidebarOpen ? <X size={20} /> : <Menu size={20} />}
          </button>
        </div>

        <nav className={styles.nav}>
          {menuItems.map((item) => (
            <Link 
              key={item.path} 
              href={item.path} 
              className={`${styles.navItem} ${pathname === item.path ? styles.active : ""}`}
            >
              <item.icon size={22} className={styles.navIcon} />
              {sidebarOpen && <span>{item.name}</span>}
              {pathname === item.path && <div className={styles.activeIndicator} />}
            </Link>
          ))}
        </nav>

        <div className={styles.sidebarFooter}>
          <button className={styles.logoutBtn} onClick={logout}>
            <LogOut size={22} />
            {sidebarOpen && <span>Logout</span>}
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <main className={styles.main}>
        {/* Header */}
        <header className={styles.header}>
          <div className={styles.headerLeft}>
             <button 
               className={styles.mobileMenuBtn}
               onClick={() => setSidebarOpen(true)}
             >
               <Menu size={20} />
             </button>
             <div className={styles.searchBox} onClick={() => setSearchOpen(true)}>
               <Search size={18} className={styles.searchIcon} />
               <div className={styles.searchPlaceholder}>Search services or pages...</div>
               <div className={styles.shortcut}>⌘ K</div>
             </div>
          </div>
          <div className={styles.headerRight}>
             <button className={styles.newBtn} onClick={() => router.push('/dashboard/services')}>
                <Plus size={18} /> New Deployment
             </button>
             <button className={styles.iconBtn}>
                <Bell size={20} />
                <span className={styles.badge} />
             </button>
             <div className={styles.userProfile}>
                <div className={styles.avatar}>
                  <User size={18} />
                </div>
                <div className={styles.userInfo}>
                   <p className={styles.userName}>{user.name || 'Enterprise Admin'}</p>
                   <p className={styles.userRole}>{user.email}</p>
                </div>
             </div>
          </div>
        </header>

        <div className={styles.content}>
          <AnimatePresence mode="wait">
            <motion.div
              key={pathname}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -10 }}
              transition={{ duration: 0.3 }}
            >
              {children}
            </motion.div>
          </AnimatePresence>
        </div>
      </main>

      {/* Search Modal (Command Palette) */}
      <AnimatePresence>
        {searchOpen && (
          <motion.div 
            className={styles.modalOverlay}
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setSearchOpen(false)}
          >
            <motion.div 
              className={styles.searchModal}
              initial={{ scale: 0.95, y: -20 }}
              animate={{ scale: 1, y: 0 }}
              exit={{ scale: 0.95, y: -20 }}
              onClick={e => e.stopPropagation()}
            >
              <div className={styles.modalSearchBox}>
                <Search size={22} color="var(--primary)" />
                <input 
                  autoFocus 
                  type="text" 
                  placeholder="Type to search pages..." 
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                />
                <button className={styles.closeBtn} onClick={() => setSearchOpen(false)}>
                  <X size={20} />
                </button>
              </div>

              <div className={styles.modalResults}>
                <p className={styles.resultsLabel}>Quick Navigation</p>
                {filteredSearchItems.length > 0 ? (
                  <div className={styles.resultsList}>
                    {filteredSearchItems.map(item => (
                      <button 
                        key={item.path} 
                        className={styles.resultItem}
                        onClick={() => {
                          router.push(item.path);
                          setSearchOpen(false);
                          setSearchQuery("");
                        }}
                      >
                        <item.icon size={18} />
                        <span>{item.name}</span>
                        <ChevronRight size={14} className={styles.itemArrow} />
                      </button>
                    ))}
                  </div>
                ) : (
                  <div className={styles.noResults}>
                    No pages found for "{searchQuery}"
                  </div>
                )}
              </div>
              
              <div className={styles.modalFooter}>
                <span>↑↓ navigate</span>
                <span>↵ select</span>
                <span>esc close</span>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}
