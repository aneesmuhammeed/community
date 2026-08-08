import React from 'react';

const complaints = [
  { id: 'C-089', title: 'Noise from Upstairs', category: 'Complaint', apt: 'C-403', time: '2h ago', status: 'in-progress' },
  { id: 'C-088', title: 'Water Leak in Bathroom', category: 'Plumbing', apt: 'B-207', time: '4h ago', status: 'open' },
  { id: 'C-087', title: 'Lift Not Working – Block A', category: 'Lift', apt: 'A-101', time: '1d ago', status: 'in-progress' },
  { id: 'C-086', title: 'CCTV Offline – Gate B', category: 'Security', apt: 'D-512', time: '2d ago', status: 'open' },
  { id: 'C-085', title: 'Lobby Area Unclean', category: 'Cleaning', apt: 'B-Block', time: '3d ago', status: 'resolved' },
];

const statusStyle: Record<string, string> = {
  open: 'bg-danger-soft text-danger',
  'in-progress': 'bg-warning-soft text-warning-foreground',
  resolved: 'bg-accent-soft text-accent',
};
const statusLabel: Record<string, string> = { open: 'Open', 'in-progress': 'In Progress', resolved: 'Resolved' };

export default function RecentComplaintsPanel() {
  return (
    <div className="bg-card border border-border rounded-xl" style={{ boxShadow: '0 2px 8px 0 rgba(30,40,80,0.06)' }}>
      <div className="px-5 py-4 border-b border-border flex items-center justify-between">
        <p className="text-sm font-semibold text-foreground font-body">Recent Complaints</p>
        <a className="text-xs font-medium text-primary font-body cursor-pointer">View all</a>
      </div>
      <div className="divide-y divide-border">
        {complaints.map((c, i) => (
          <div key={i} className="px-5 py-3.5 flex items-center gap-3">
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 mb-0.5">
                <span className="text-xs text-muted-foreground font-body font-medium">{c.id}</span>
                <span className="text-xs text-muted-foreground">·</span>
                <span className="text-xs text-muted-foreground font-body">{c.apt}</span>
              </div>
              <p className="text-sm font-medium text-foreground font-body truncate">{c.title}</p>
              <p className="text-xs text-muted-foreground font-body mt-0.5">{c.time}</p>
            </div>
            <span className={`text-xs font-medium font-body px-2 py-1 rounded-md flex-shrink-0 ${statusStyle[c.status]}`}>
              {statusLabel[c.status]}
            </span>
          </div>
        ))}
      </div>
    </div>
  );
}
