import React from 'react';

const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const paid =    [88, 92, 85, 90, 94, 87, 91, 96, 89, 93, 85, 90];
const overdue = [12, 18, 22, 15, 10, 20, 14, 8, 17, 13, 22, 16];
const maxVal = 100;
const chartH = 120;

export default function MaintenanceLineChart() {
  return (
    <div className="bg-card border border-border rounded-xl p-5" style={{ boxShadow: '0 2px 8px 0 rgba(30,40,80,0.06)', height: '100%' }}>
      <div className="flex items-center justify-between mb-4">
        <div>
          <p className="text-sm font-semibold text-foreground font-body">Monthly Maintenance Collection</p>
          <p className="text-xs text-muted-foreground font-body mt-0.5">Paid vs Overdue — FY 2024</p>
        </div>
        <div className="flex items-center gap-4 text-xs font-medium font-body">
          <div className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-full bg-primary inline-block"></span>Paid</div>
          <div className="flex items-center gap-1.5"><span className="w-3 h-3 rounded-full bg-warning inline-block"></span>Overdue</div>
        </div>
      </div>

      {/* Chart area */}
      <div className="relative" style={{ height: `${chartH + 30}px` }}>
        {/* Y grid lines */}
        {[0, 25, 50, 75, 100].map((v, i) => (
          <div key={i} className="absolute w-full border-t border-border" style={{ bottom: `${(v / maxVal) * chartH + 20}px` }}>
            <span className="absolute -left-1 -translate-y-1/2 text-xs text-muted-foreground font-body" style={{ fontSize: '10px', left: 0 }}>{v}%</span>
          </div>
        ))}

        {/* SVG polylines */}
        <svg className="absolute left-6 right-0 top-0" style={{ height: `${chartH}px`, width: 'calc(100% - 24px)' }} preserveAspectRatio="none">
          {/* Paid line */}
          <polyline
            points={paid.map((v, i) => `${(i / (paid.length - 1)) * 100}% ${chartH - (v / maxVal) * chartH}px`).join(' ')}
            fill="none"
            stroke="#2563eb"
            strokeWidth="2.5"
            strokeLinejoin="round"
            strokeLinecap="round"
          />
          {/* Overdue line */}
          <polyline
            points={overdue.map((v, i) => `${(i / (overdue.length - 1)) * 100}% ${chartH - (v / maxVal) * chartH}px`).join(' ')}
            fill="none"
            stroke="#f59e0b"
            strokeWidth="2.5"
            strokeLinejoin="round"
            strokeLinecap="round"
          />
          {/* Dots – paid */}
          {paid.map((v, i) => (
            <circle key={`p-${i}`} cx={`${(i / (paid.length - 1)) * 100}%`} cy={`${chartH - (v / maxVal) * chartH}px`} r="3.5" fill="#2563eb" />
          ))}
          {/* Dots – overdue */}
          {overdue.map((v, i) => (
            <circle key={`o-${i}`} cx={`${(i / (overdue.length - 1)) * 100}%`} cy={`${chartH - (v / maxVal) * chartH}px`} r="3.5" fill="#f59e0b" />
          ))}
        </svg>

        {/* X labels */}
        <div className="absolute bottom-0 left-6 right-0 flex justify-between">
          {months.map((m, i) => (
            <span key={i} className="text-muted-foreground font-body" style={{ fontSize: '10px' }}>{m}</span>
          ))}
        </div>
      </div>
    </div>
  );
}
