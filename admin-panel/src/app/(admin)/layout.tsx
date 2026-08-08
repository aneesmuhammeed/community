import styles from './layout.module.css';
import Link from 'next/link';
import { 
  LayoutDashboard, Users, UserCheck, Calendar, 
  MessageSquare, Wrench, Bell, Radio, 
  BarChart3, Settings, Moon, BellRing
} from 'lucide-react';

import { supabase } from '@/lib/supabase';
import SidebarNav from '@/components/SidebarNav';

export const revalidate = 0;

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const SOCIETY_ID = process.env.NEXT_PUBLIC_SOCIETY_ID || '11111111-1111-1111-1111-111111111111';
  
  const [
    { count: unresolvedComplaints },
    { count: activeVisitors }
  ] = await Promise.all([
    supabase.from('complaints').select('*', { count: 'exact', head: true }).eq('society_id', SOCIETY_ID).neq('status', 'resolved'),
    supabase.from('visitors').select('*', { count: 'exact', head: true }).eq('society_id', SOCIETY_ID).eq('status', 'active')
  ]);

  const totalNotifications = (unresolvedComplaints || 0) + (activeVisitors || 0);
  return (
    <div className={styles.layout}>
      {/* Sidebar */}
      <aside className={styles.sidebar}>
        <div className={styles.sidebarHeader}>
          <div className={styles.logo}>
            <div className={styles.logoIcon}></div>
            <div className={styles.logoText}>
              <span className={styles.logoTitle}>Community Hub</span>
              <span className={styles.logoBadge}>Admin</span>
            </div>
          </div>
          
          <div className={styles.residencyInfo}>
            <div className={styles.residencyAvatar}>M</div>
            <div className={styles.residencyDetails}>
              <span className={styles.residencyName}>Maple Heights</span>
              <span className={styles.residencySub}>Residency</span>
            </div>
          </div>
        </div>

        <SidebarNav />
        
        <div className={styles.sidebarFooter}>
          <span>v1.0.0 · CommunityHub</span>
        </div>
      </aside>

      {/* Main Content Area */}
      <div className={styles.mainWrapper}>
        <header className={styles.header}>
          <div className={styles.breadcrumbs}>
            <span className={styles.breadcrumbItem}>/</span>
            <span className={styles.breadcrumbCurrent}>Dashboard</span>
          </div>
          
          <div className={styles.headerActions}>
            <button className={styles.iconBtn}>
              <Moon size={20} />
            </button>
            <button className={styles.iconBtn}>
              {totalNotifications > 0 && <div className={styles.notificationBadge}>{totalNotifications}</div>}
              <BellRing size={20} />
            </button>
            <div className={styles.userProfile}>
              <div className={styles.userAvatar}>SA</div>
              <div className={styles.userDetails}>
                <span className={styles.userName}>Super Admin</span>
                <span className={styles.userRole}>Maple Heights</span>
              </div>
            </div>
          </div>
        </header>
        
        <main className={styles.mainContent}>
          {children}
        </main>
      </div>
    </div>
  );
}
