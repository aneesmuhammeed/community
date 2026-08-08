import React from 'react';

const segments = [
  { label: 'Clubhouse', pct: 35, color: '#2563eb' },
  { label: 'Gym', pct: 25, color: '#10b981' },
  { label: 'Party Hall', pct: 18, color: '#f59e0b' },
  { label: 'Pool', pct: 14, color: '#6366f1' },
  { label: 'Tennis Court', pct: 8, color: '#ef4444' },
];

const cx = 80, cy = 80, r = 60, innerR = 38;
const circumference = 2 * Math.PI * r;

function buildSegments() {
  let offset = 0;
  return segments.map(s => {
    const dash = (s.pct / 100) * circumference;
    const gap = circumference - dash;
    const seg = { ...s, dash, gap, offset };
    offset += dash;
    return seg;
  });
}

export default function FacilityDonutChart() {
  const segs = buildSegments();
  return (
    <div className="bg-card border border-border rounded-xl p-5 flex flex-col justify-center" style={{ boxShadow: '0 2px 8px 0 rgba(30,40,80,0.06)', height: '100%' }}>
      <div className="mb-4">
        <p className="text-sm font-semibold text-foreground font-body">Facility Usage This Week</p>
        <p className="text-xs text-muted-foreground font-body mt-0.5">By booking count</p>
      </div>

      <div className="flex items-center gap-6">
        {/* Donut SVG */}
        <div className="flex-shrink-0">
          <svg width="160" height="160" viewBox="0 0 160 160">
            {segs.map((s, i) => (
              <circle
                key={i}
                cx={cx}
                cy={cy}
                r={r}
                fill="none"
                stroke={s.color}
                strokeWidth="22"
                strokeDasharray={`${s.dash} ${s.gap}`}
                strokeDashoffset={-s.offset + circumference * 0.25}
                strokeLinecap="butt"
              />
            ))}
            {/* Center label */}
            <text x={cx} y={cy - 6} textAnchor="middle" fontSize="16" fontWeight="600" fill="var(--color-foreground)" fontFamily="Inter">100%</text>
            <text x={cx} y={cy + 12} textAnchor="middle" fontSize="10" fill="var(--color-muted-foreground)" fontFamily="Inter">booked</text>
          </svg>
        </div>

        {/* Legend */}
        <div className="flex flex-col gap-2.5 flex-1">
          {segments.map((s, i) => (
            <div key={i} className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <span className="w-2.5 h-2.5 rounded-full flex-shrink-0" style={{ background: s.color }}></span>
                <span className="text-xs font-body text-foreground">{s.label}</span>
              </div>
              <span className="text-xs font-semibold font-body text-foreground">{s.pct}%</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
