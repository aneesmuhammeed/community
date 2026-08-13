import styles from './layout.module.css';
import { Moon, BellRing, LogOut } from 'lucide-react';

import { createClient } from '@/utils/supabase/server';
import { logout } from '@/app/login/actions';
import SidebarNav from '@/components/SidebarNav';
import MobileNav from '@/components/MobileNav';
import SOSListener from '@/components/SOSListener';

export const revalidate = 0;

function SidebarContent({ role }: { role: string }) {
  return (
    <>
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

      <SidebarNav role={role} />
      
      <div className={styles.sidebarFooter}>
        <span>v1.0.0 · CommunityHub</span>
      </div>
    </>
  );
}

import SocietySwitcher from '@/components/SocietySwitcher';
import { getSocietyId } from '@/utils/supabase/auth';

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const SOCIETY_ID = await getSocietyId();
  const supabase = await createClient();
  
  // Get User Role from JWT
  const { data: { user } } = await supabase.auth.getUser();
  const role = user?.app_metadata?.role || 'SUPER_ADMIN';

  // Format the display name based on role
  let roleDisplayName = 'Super Admin';
  let roleInitials = 'SA';
  if (role === 'SECURITY_GUARD') {
    roleDisplayName = 'Security Guard';
    roleInitials = 'SG';
  } else if (role === 'COMMUNITY_HEAD') {
    roleDisplayName = 'Community Head';
    roleInitials = 'CH';
  }

  const [
    { count: unresolvedComplaints },
    { count: activeVisitors }
  ] = await Promise.all([
    supabase.from('complaints').select('*', { count: 'exact', head: true }).eq('society_id', SOCIETY_ID).neq('status', 'resolved'),
    supabase.from('visitors').select('*', { count: 'exact', head: true }).eq('society_id', SOCIETY_ID).eq('status', 'active')
  ]);

  const totalNotifications = (unresolvedComplaints || 0) + (activeVisitors || 0);

  let societies: any[] = [];
  if (role === 'SUPER_ADMIN') {
    const { data } = await supabase.from('societies').select('id, name');
    societies = data || [];
  }

  return (
    <div className={styles.layout}>
      <SOSListener />
      {/* Desktop/Tablet Sidebar (hidden on mobile via CSS) */}
      <aside className={styles.sidebar}>
        <SidebarContent role={role} />
      </aside>

      {/* Mobile Drawer */}
      <MobileNav>
        <SidebarContent role={role} />
      </MobileNav>

      {/* Main Content Area */}
      <div className={styles.mainWrapper}>
        <header className={styles.header}>
          <div className={styles.breadcrumbs}>
            <span className={styles.breadcrumbItem}>/</span>
            <span className={styles.breadcrumbCurrent}>Dashboard</span>
            {role === 'SUPER_ADMIN' && (
              <div style={{ marginLeft: '16px' }}>
                <SocietySwitcher societies={societies} currentSocietyId={SOCIETY_ID} />
              </div>
            )}
          </div>
          
          <div className={styles.headerActions}>
            <button className={styles.iconBtn}>
              <Moon size={18} />
            </button>
            <button className={styles.iconBtn}>
              {totalNotifications > 0 && <div className={styles.notificationBadge}>{totalNotifications}</div>}
              <BellRing size={18} />
            </button>
            <div className={styles.userProfile}>
              <div className={styles.userAvatar}>
                {roleInitials}
              </div>
              <div className={styles.userDetails}>
                <span className={styles.userName}>
                  {roleDisplayName}
                </span>
                <span className={styles.userRole}>Maple Heights</span>
              </div>
            </div>
            
            <form action={logout}>
              <button className={styles.logoutButton} title="Logout">
                <LogOut size={20} color="#64748b" />
              </button>
            </form>
          </div>
        </header>
        
        <main className={styles.mainContent}>
          {children}
        </main>
      </div>
    </div>
  );
}
