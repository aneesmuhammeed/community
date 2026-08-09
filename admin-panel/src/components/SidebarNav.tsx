"use client";

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  LayoutDashboard, Users, UserCheck, Calendar, 
  MessageSquare, Wrench, Bell, Radio, 
  BarChart3, Settings, ScanLine
} from 'lucide-react';
import styles from '@/app/(admin)/layout.module.css';

const NAV_ITEMS = [
  { href: '/dashboard', icon: LayoutDashboard, label: 'Dashboard' },
  { href: '/scanner', icon: ScanLine, label: 'QR Scanner' },
  { href: '/residents', icon: Users, label: 'Residents' },
  { href: '/visitors', icon: UserCheck, label: 'Visitors' },
  { href: '/facilities', icon: Calendar, label: 'Facilities' },
  { href: '/complaints', icon: MessageSquare, label: 'Complaints' },
  { href: '/maintenance', icon: Wrench, label: 'Maintenance' },
  { href: '/announcements', icon: Bell, label: 'Announcements' },
  { href: '/feed', icon: Radio, label: 'Feed' },
  { href: '/reports', icon: BarChart3, label: 'Reports' },
  { href: '/settings', icon: Settings, label: 'Settings' },
];

export default function SidebarNav() {
  const pathname = usePathname();

  return (
    <nav className={styles.nav}>
      {NAV_ITEMS.map((item) => {
        const isActive = pathname.startsWith(item.href);
        const Icon = item.icon;
        
        return (
          <Link 
            key={item.href} 
            href={item.href} 
            className={`${styles.navItem} ${isActive ? styles.active : ''}`}
            title={item.label}
          >
            <Icon size={18} />
            <span className={styles.navLabel}>{item.label}</span>
            <span className={styles.navTooltip}>{item.label}</span>
          </Link>
        );
      })}
    </nav>
  );
}
