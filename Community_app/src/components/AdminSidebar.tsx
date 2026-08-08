import Icon from '@/components/Icon';

const navItems = [
  { icon: 'layout-dashboard', label: 'Dashboard', active: false },
  { icon: 'users', label: 'Residents Management', active: true },
  { icon: 'shield-check', label: 'Visitor Control', active: false },
  { icon: 'calendar', label: 'Facility Bookings', active: false },
  { icon: 'message-circle', label: 'Complaints & Tickets', active: false },
  { icon: 'wrench', label: 'Maintenance & Billing', active: false },
  { icon: 'megaphone', label: 'Announcements', active: false },
  { icon: 'newspaper', label: 'Community Feed', active: false },
  { icon: 'bar-chart-2', label: 'Reports & Analytics', active: false },
  { icon: 'settings', label: 'Settings', active: false },
];

export default function AdminSidebar({ activeIndex = 0 }) {
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
        {navItems.map((item, i) => (
          <a key={i} className={`flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium font-body ${item.active ? 'bg-secondary text-primary' : 'text-muted-foreground'}`}>
            <Icon i={item.icon} size={17} className={item.active ? 'text-primary' : 'text-muted-foreground'} />
            {item.label}
          </a>
        ))}
      </nav>
      <div className="px-5 py-4 border-t border-border">
        <p className="text-xs text-muted-foreground font-body">v1.0.0 · CommunityHub</p>
      </div>
    </div>
  );
}
