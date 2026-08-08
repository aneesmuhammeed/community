import React from 'react';
import Icon from '@/components/Icon';
import UserAvatar from '@/components/UserAvatar';

const visitors = [
  { name: 'Sunita Verma', host: 'Arjun Mehta · C-403', purpose: 'Personal Visit', time: '4:30 PM', gender: 'female', heritage: 'South Asian', idx: 1 },
  { name: 'David Okafor', host: 'Priya Nair · B-207', purpose: 'Package Delivery', time: '5:00 PM', gender: 'male', heritage: 'African', idx: 6 },
  { name: 'Thomas Rajan', host: 'Sneha Iyer · A-101', purpose: 'Business Meeting', time: '3:15 PM', gender: 'male', heritage: 'South Asian', idx: 4 },
  { name: 'Fatima Al-Rashid', host: 'Omar Khan · D-512', purpose: 'Personal Visit', time: '2:45 PM', gender: 'female', heritage: 'Middle Eastern', idx: 8 },
  { name: 'Karan Singh', host: 'Meera Pillai · A-205', purpose: 'Service Visit', time: '1:30 PM', gender: 'male', heritage: 'South Asian', idx: 3 },
];

export default function VisitorApprovalsPanel() {
  return (
    <div className="bg-card border border-border rounded-xl" style={{ boxShadow: '0 2px 8px 0 rgba(30,40,80,0.06)' }}>
      <div className="px-5 py-4 border-b border-border flex items-center justify-between">
        <p className="text-sm font-semibold text-foreground font-body">Today's Visitor Approvals</p>
        <span className="bg-secondary text-secondary-foreground text-xs font-semibold font-body px-2 py-0.5 rounded-md">5 pending</span>
      </div>
      <div className="divide-y divide-border">
        {visitors.map((v, i) => (
          <div key={i} className="px-5 py-3.5 flex items-center gap-3">
            <UserAvatar gender={v.gender} heritage={v.heritage} index={v.idx} className="w-9 h-9 rounded-full flex-shrink-0" />
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium text-foreground font-body">{v.name}</p>
              <p className="text-xs text-muted-foreground font-body mt-0.5 truncate">{v.host} · {v.purpose}</p>
              <p className="text-xs text-muted-foreground font-body">{v.time}</p>
            </div>
            <div className="flex items-center gap-2 flex-shrink-0">
              <button className="px-3 py-1.5 rounded-lg bg-accent-soft text-accent text-xs font-semibold font-body flex items-center gap-1 border-none cursor-pointer">
                <Icon i="check" size={12} />
                Approve
              </button>
              <button className="px-3 py-1.5 rounded-lg bg-danger-soft text-danger text-xs font-semibold font-body flex items-center gap-1 border-none cursor-pointer">
                <Icon i="x" size={12} />
                Deny
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
