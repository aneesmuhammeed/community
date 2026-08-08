import React from 'react';
import Icon from '@/components/Icon';

const navItems = [
  { icon: 'layout-dashboard', label: 'Dashboard' },
  { icon: 'users', label: 'Residents Management' },
  { icon: 'shield-check', label: 'Visitor Control' },
  { icon: 'calendar', label: 'Facility Bookings' },
  { icon: 'message-circle', label: 'Complaints & Tickets' },
  { icon: 'wrench', label: 'Maintenance & Billing' },
  { icon: 'megaphone', label: 'Announcements' },
  { icon: 'newspaper', label: 'Community Feed' },
  { icon: 'bar-chart-2', label: 'Reports & Analytics' },
  { icon: 'settings', label: 'Settings' },
];

export default function AdminSidebarResidents() {
  return (
    <div className="flex flex-col bg-background border-r border-border" style={{ width: '240px', minHeight: '100%' }}>
      <div className="px-5 py-5 border-b border-border flex items-center gap-3">
        <div className="w-9 h-9 rounded-lg bg-primary flex items-center justify-center flex-shrink-0">
          <Icon i="building-2" size={18} className="text-primary-foreground" />
        </div>
        <div className="min-w-0">
          <p className="text-xs font-semibold text-foreground font-body leading-tight">Maple Heights</p>
          <p className="text-xs text-muted-foreground font-body">Residency</p>
        </div>
      </div>
      <nav className="flex-1 px-3 py-4 flex flex-col gap-0.5">
        {navItems.map((item, i) => {
          const isActive = i === 1; // 1 is Residents Management
          return (
            <a key={i} className={`flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium font-body ${isActive ? 'bg-secondary text-primary' : 'text-muted-foreground'}`}>
              <Icon i={item.icon} size={17} className={isActive ? 'text-primary' : 'text-muted-foreground'} />
              {item.label}
            </a>
          );
        })}
      </nav>
      <div className="px-5 py-4 border-t border-border">
        <p className="text-xs text-muted-foreground font-body">v1.0.0 · CommunityHub</p>
      </div>
    </div>
  );
}
