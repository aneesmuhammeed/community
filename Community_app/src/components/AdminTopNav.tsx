import Icon from '@/components/Icon';

export default function AdminTopNav() {
  return (
    <div className="bg-background border-b border-border px-6 py-0 flex items-center justify-between" style={{ height: '60px' }}>
      {/* Left: Logo */}
      <div className="flex items-center gap-3">
        <div className="flex items-center gap-2">
          <Icon i="building-2" size={20} className="text-primary" />
          <span className="text-base font-semibold text-foreground font-body">Community Hub</span>
        </div>
        <span className="bg-secondary text-secondary-foreground text-xs font-semibold font-body px-2 py-0.5 rounded-md">Admin</span>
        <div className="flex items-center gap-1.5 ml-3">
          <span className="text-muted-foreground text-sm">/</span>
          <span className="text-sm text-muted-foreground font-body">Dashboard</span>
        </div>
      </div>

      {/* Right */}
      <div className="flex items-center gap-3">
        {/* Dark mode toggle */}
        <button className="w-8 h-8 rounded-lg bg-muted flex items-center justify-center border-none cursor-pointer">
          <Icon i="moon" size={16} className="text-muted-foreground" />
        </button>

        {/* Bell */}
        <div className="relative">
          <button className="w-8 h-8 rounded-lg bg-muted flex items-center justify-center border-none cursor-pointer">
            <Icon i="bell" size={16} className="text-muted-foreground" />
          </button>
          <span className="absolute -top-1 -right-1 w-4 h-4 rounded-full bg-danger flex items-center justify-center">
            <span className="text-primary-foreground font-bold font-body" style={{ fontSize: '9px' }}>3</span>
          </span>
        </div>

        {/* Admin Avatar */}
        <div className="flex items-center gap-2 pl-2 border-l border-border ml-1">
          <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center">
            <span className="text-primary-foreground font-semibold font-body text-xs">SA</span>
          </div>
          <div>
            <p className="text-xs font-semibold text-foreground font-body leading-tight">Super Admin</p>
            <p className="text-xs text-muted-foreground font-body">Maple Heights</p>
          </div>
          <Icon i="chevron-down" size={14} className="text-muted-foreground" />
        </div>
      </div>
    </div>
  );
}
