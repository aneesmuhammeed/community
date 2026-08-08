import Icon from '@/components/Icon';

const colorMap: Record<string, any> = {
  green: { badge: 'bg-accent-soft text-accent', icon: 'bg-accent-soft', iconColor: 'text-accent', trend: 'text-accent' },
  red: { badge: 'bg-danger-soft text-danger', icon: 'bg-danger-soft', iconColor: 'text-danger', trend: 'text-danger' },
  blue: { badge: 'bg-secondary text-secondary-foreground', icon: 'bg-secondary', iconColor: 'text-primary', trend: 'text-primary' },
  orange: { badge: 'bg-warning-soft text-warning-foreground', icon: 'bg-warning-soft', iconColor: 'text-warning-foreground', trend: 'text-warning-foreground' },
};

export default function KPICard({
  title = 'Total Residents',
  value = '248',
  badge = '+4 this month',
  badgeColor = 'green',
  icon = 'users',
  trendIcon = 'trending-up',
}) {
  const c = colorMap[badgeColor] || colorMap.blue;
  return (
    <div className="bg-card border border-border rounded-xl p-5 flex-1" style={{ boxShadow: '0 2px 8px 0 rgba(30,40,80,0.06)' }}>
      <div className="flex items-start justify-between mb-4">
        <div className={`w-10 h-10 rounded-lg flex items-center justify-center ${c.icon}`}>
          <Icon i={icon} size={19} className={c.iconColor} />
        </div>
        <div className={`flex items-center gap-1 px-2 py-1 rounded-lg text-xs font-medium font-body ${c.badge}`}>
          <Icon i={trendIcon} size={12} />
          {badge}
        </div>
      </div>
      <p className="text-2xl font-semibold text-foreground font-body mb-1">{value}</p>
      <p className="text-sm text-muted-foreground font-body">{title}</p>
    </div>
  );
}
