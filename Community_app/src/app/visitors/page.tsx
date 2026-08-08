import React from 'react';
import Icon from '@/components/Icon';
import UserAvatar from '@/components/UserAvatar';
import AdminTopNav from '@/components/AdminTopNav';
import AdminSidebarVisitor from '@/components/AdminSidebarVisitor';

const purposeMap: Record<string, { icon: string; color: string; bg: string }> = {
  'Food Delivery': { icon: 'package', color: 'text-warning-foreground', bg: 'bg-warning-soft' },
  'Guest': { icon: 'user', color: 'text-primary', bg: 'bg-secondary' },
  'Service': { icon: 'wrench', color: 'text-muted-foreground', bg: 'bg-muted' },
  'Courier': { icon: 'truck', color: 'text-accent', bg: 'bg-accent-soft' },
  'Business': { icon: 'briefcase', color: 'text-secondary-foreground', bg: 'bg-secondary' },
};

const pendingApprovals = [
  { name: 'Ramesh Delivery', purpose: 'Food Delivery', host: 'Arjun Mehta', unit: 'C-403', time: '5:45 PM', duration: '15 mins', method: 'QR', ago: '3 mins ago', gender: 'male', heritage: 'South Asian', idx: 1 },
  { name: 'Anil Sharma', purpose: 'Guest', host: 'Priya Nair', unit: 'B-207', time: '6:00 PM', duration: '2 hours', method: 'OTP', ago: '5 mins ago', gender: 'male', heritage: 'South Asian', idx: 4 },
  { name: 'BlueDart Courier', purpose: 'Courier', host: 'Omar Khan', unit: 'D-512', time: '5:50 PM', duration: '10 mins', method: 'Manual', ago: '7 mins ago', gender: 'male', heritage: 'Middle Eastern', idx: 6 },
  { name: 'Suresh Plumber', purpose: 'Service', host: 'Rajesh Sharma', unit: 'C-301', time: '6:15 PM', duration: '1 hour', method: 'OTP', ago: '12 mins ago', gender: 'male', heritage: 'South Asian', idx: 8 },
  { name: 'Neha Kapoor', purpose: 'Guest', host: 'Meera Pillai', unit: 'A-205', time: '6:30 PM', duration: '3 hours', method: 'QR', ago: '15 mins ago', gender: 'female', heritage: 'South Asian', idx: 2 },
];

const liveLog = [
  { name: 'Kavita Singh', purpose: 'Guest', entry: '5:32 PM', exit: '—', approvedBy: 'Ananya Singh · C-108', status: 'Entered', isNewest: true },
  { name: 'Zomato Delivery', purpose: 'Food Delivery', entry: '5:28 PM', exit: '5:31 PM', approvedBy: 'Vikram Desai · B-312', status: 'Exited', isNewest: false },
  { name: 'SBI Tech Support', purpose: 'Service', entry: '4:55 PM', exit: '—', approvedBy: 'Omar Khan · D-512', status: 'Overstayed', isNewest: false },
  { name: 'Ravi Kumar', purpose: 'Guest', entry: '4:40 PM', exit: '5:10 PM', approvedBy: 'Meera Pillai · A-205', status: 'Exited', isNewest: false },
  { name: 'Amazon Courier', purpose: 'Courier', entry: '—', exit: '—', approvedBy: '—', status: 'Denied', isNewest: false },
  { name: 'Pooja Iyer', purpose: 'Guest', entry: '4:15 PM', exit: '—', approvedBy: 'Arjun Mehta · C-403', status: 'Entered', isNewest: false },
  { name: 'Swiggy Delivery', purpose: 'Food Delivery', entry: '4:02 PM', exit: '4:05 PM', approvedBy: 'Priya Nair · B-207', status: 'Exited', isNewest: false },
];

const logTable = [
  { name: 'Kavita Singh', purpose: 'Guest', host: 'Ananya Singh', unit: 'C-108', arrival: '5:32 PM', departure: '—', method: 'QR', status: 'Entered' },
  { name: 'Zomato Delivery', purpose: 'Food Delivery', host: 'Vikram Desai', unit: 'B-312', arrival: '5:28 PM', departure: '5:31 PM', method: 'OTP', status: 'Exited' },
  { name: 'SBI Tech Support', purpose: 'Service', host: 'Omar Khan', unit: 'D-512', arrival: '4:55 PM', departure: '—', method: 'Manual', status: 'Overstayed' },
  { name: 'Ravi Kumar', purpose: 'Guest', host: 'Meera Pillai', unit: 'A-205', arrival: '4:40 PM', departure: '5:10 PM', method: 'QR', status: 'Exited' },
  { name: 'Amazon Courier', purpose: 'Courier', host: 'Rohan Gupta', unit: 'D-201', arrival: '—', departure: '—', method: 'Manual', status: 'Denied' },
  { name: 'Pooja Iyer', purpose: 'Guest', host: 'Arjun Mehta', unit: 'C-403', arrival: '4:15 PM', departure: '—', method: 'OTP', status: 'Entered' },
  { name: 'Swiggy Delivery', purpose: 'Food Delivery', host: 'Priya Nair', unit: 'B-207', arrival: '4:02 PM', departure: '4:05 PM', method: 'QR', status: 'Exited' },
];

const statusStyle: Record<string, string> = {
  Entered: 'bg-secondary text-secondary-foreground',
  Exited: 'bg-accent-soft text-accent',
  Denied: 'bg-danger-soft text-danger',
  Overstayed: 'bg-warning-soft text-warning-foreground',
};

const statCards = [
  { label: 'Currently Inside', value: '8', icon: 'door-open', color: 'text-primary', bg: 'bg-secondary', dot: 'bg-primary' },
  { label: 'Awaiting Approval', value: '5', icon: 'clock', color: 'text-warning-foreground', bg: 'bg-warning-soft', dot: 'bg-warning' },
  { label: 'Approved Today', value: '34', icon: 'check-circle', color: 'text-accent', bg: 'bg-accent-soft', dot: 'bg-accent' },
  { label: 'Denied Today', value: '3', icon: 'x-circle', color: 'text-danger', bg: 'bg-danger-soft', dot: 'bg-danger' },
];

export default function VisitorControlScreen() {
  return (
    <div className="bg-input font-body flex flex-col" style={{ minHeight: '100vh' }}>
      <AdminTopNav />

      <div className="flex flex-1">
        <AdminSidebarVisitor />

        {/* Main */}
        <div className="flex-1 px-8 py-7 flex flex-col gap-6 min-w-0">

          {/* Page Header */}
          <div className="flex items-start justify-between">
            <div>
              <p className="text-xl font-semibold text-foreground font-body">Visitor Control Center</p>
              <p className="text-sm text-muted-foreground font-body mt-0.5">Gate Management &amp; Entry Logs</p>
            </div>
            <div className="flex items-center gap-2.5">
              <div className="flex items-center gap-2 bg-card border border-border rounded-lg px-3 py-2" style={{ boxShadow: '0 1px 4px 0 rgba(30,40,80,0.05)' }}>
                <Icon i="calendar" size={14} className="text-muted-foreground" />
                <span className="text-sm font-medium text-foreground font-body">Nov 28, 2024</span>
                <Icon i="chevron-down" size={13} className="text-muted-foreground" />
              </div>
              <button className="flex items-center gap-1.5 px-4 py-2 rounded-lg bg-primary text-primary-foreground text-sm font-semibold font-body border-none cursor-pointer" style={{ boxShadow: '0 4px 12px 0 rgba(37,99,235,0.25)' }}>
                <Icon i="plus" size={15} />
                Manual Entry
              </button>
            </div>
          </div>

          {/* Live Stats Strip */}
          <div className="flex gap-4">
            {statCards.map((s, i) => (
              <div key={i} className="flex-1 bg-card border border-border rounded-xl px-4 py-3.5 flex items-center gap-3" style={{ boxShadow: '0 2px 8px 0 rgba(30,40,80,0.06)' }}>
                <div className={`w-9 h-9 rounded-lg flex items-center justify-center flex-shrink-0 ${s.bg}`}>
                  <Icon i={s.icon} size={18} className={s.color} />
                </div>
                <div>
                  <p className="text-2xl font-semibold text-foreground font-body leading-none">{s.value}</p>
                  <div className="flex items-center gap-1.5 mt-1">
                    <span className={`w-1.5 h-1.5 rounded-full flex-shrink-0 ${s.dot}`}></span>
                    <p className="text-xs text-muted-foreground font-body">{s.label}</p>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {/* Split View */}
          <div className="flex gap-5">

            {/* Left: Pending Approvals */}
            <div className="flex flex-col gap-3" style={{ flex: '0 0 55%' }}>
              <div className="flex items-center gap-2">
                <p className="text-sm font-semibold text-foreground font-body">Pending Approvals</p>
                <span className="bg-warning-soft text-warning-foreground text-xs font-semibold font-body px-2 py-0.5 rounded-full">5</span>
                <span className="ml-auto flex items-center gap-1 text-xs text-accent font-body font-medium">
                  <span className="w-2 h-2 rounded-full bg-accent inline-block"></span>
                  Live
                </span>
              </div>

              <div className="flex flex-col gap-3">
                {pendingApprovals.map((v, i) => {
                  const p = purposeMap[v.purpose] || purposeMap['Guest'];
                  const methodIcon = v.method === 'QR' ? 'qr-code' : v.method === 'OTP' ? 'hash' : 'user-check';
                  return (
                    <div key={i} className="bg-card border border-border rounded-xl p-4" style={{ borderColor: 'rgba(245,158,11,0.35)', boxShadow: '0 2px 8px 0 rgba(30,40,80,0.06)' }}>
                      <div className="flex items-start gap-3 mb-3">
                        <UserAvatar gender={v.gender} heritage={v.heritage} ageGroup="25-35" index={v.idx} className="w-10 h-10 rounded-full flex-shrink-0" />
                        <div className="flex-1 min-w-0">
                          <div className="flex items-center gap-2 mb-0.5">
                            <p className="text-sm font-semibold text-foreground font-body">{v.name}</p>
                            <div className={`flex items-center gap-1 px-1.5 py-0.5 rounded-md ${p.bg}`}>
                              <Icon i={p.icon} size={11} className={p.color} />
                              <span className={`text-xs font-medium font-body ${p.color}`}>{v.purpose}</span>
                            </div>
                          </div>
                          <p className="text-xs text-muted-foreground font-body">Requested by {v.host} · {v.unit}</p>
                        </div>
                        <span className="text-xs text-muted-foreground font-body flex-shrink-0">{v.ago}</span>
                      </div>

                      <div className="flex items-center gap-4 mb-3 text-xs text-muted-foreground font-body">
                        <div className="flex items-center gap-1">
                          <Icon i="clock" size={12} />
                          {v.time} · {v.duration}
                        </div>
                        <div className="flex items-center gap-1">
                          <Icon i={methodIcon} size={12} />
                          {v.method}
                        </div>
                      </div>

                      <div className="flex gap-2">
                        <button className="flex-1 flex items-center justify-center gap-1.5 py-2 rounded-lg bg-accent-soft text-accent text-sm font-semibold font-body border border-accent cursor-pointer">
                          <Icon i="check" size={14} />
                          Approve
                        </button>
                        <button className="flex-1 flex items-center justify-center gap-1.5 py-2 rounded-lg bg-background text-danger text-sm font-semibold font-body border border-danger cursor-pointer">
                          <Icon i="x" size={14} />
                          Deny
                        </button>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Right: Live Entry Log */}
            <div className="flex flex-col gap-3 flex-1">
              <div className="flex items-center gap-2">
                <p className="text-sm font-semibold text-foreground font-body">Live Entry Log</p>
                <span className="ml-auto flex items-center gap-1 text-xs text-accent font-body font-medium">
                  <span className="w-2 h-2 rounded-full bg-accent inline-block"></span>
                  Real-time
                </span>
              </div>

              <div className="bg-card border border-border rounded-xl overflow-hidden flex flex-col" style={{ boxShadow: '0 2px 8px 0 rgba(30,40,80,0.06)' }}>
                {liveLog.map((e, i) => {
                  const p = purposeMap[e.purpose] || purposeMap['Guest'];
                  return (
                    <div key={i} className={`px-4 py-3.5 flex items-start gap-3 ${i < liveLog.length - 1 ? 'border-b border-border' : ''} ${e.isNewest ? 'bg-secondary' : ''}`}>
                      <div className={`w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0 ${p.bg}`}>
                        <Icon i={p.icon} size={15} className={p.color} />
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 mb-0.5">
                          <p className="text-sm font-medium text-foreground font-body">{e.name}</p>
                          <span className={`text-xs font-medium font-body px-1.5 py-0.5 rounded-md ${statusStyle[e.status]}`}>{e.status}</span>
                        </div>
                        <p className="text-xs text-muted-foreground font-body">{e.approvedBy}</p>
                        <div className="flex items-center gap-3 mt-1 text-xs text-muted-foreground font-body">
                          <span>In: {e.entry}</span>
                          {e.exit !== '—' && <span>Out: {e.exit}</span>}
                        </div>
                      </div>
                      <button className="w-7 h-7 rounded-lg bg-muted flex items-center justify-center flex-shrink-0 border-none cursor-pointer">
                        <Icon i="tv-2" size={13} className="text-muted-foreground" />
                      </button>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>

          {/* Full Log Table */}
          <div>
            <div className="flex items-center justify-between mb-3">
              <p className="text-sm font-semibold text-foreground font-body">Today's Full Visitor Log</p>
              <div className="flex items-center gap-2 bg-card border border-border rounded-lg px-3 py-2" style={{ boxShadow: '0 1px 4px 0 rgba(30,40,80,0.04)' }}>
                <Icon i="search" size={14} className="text-muted-foreground" />
                <span className="text-sm text-muted-foreground font-body">Search visitors…</span>
              </div>
            </div>

            <div className="bg-card border border-border rounded-xl overflow-hidden" style={{ boxShadow: '0 2px 8px 0 rgba(30,40,80,0.06)' }}>
              <table className="w-full" style={{ borderCollapse: 'collapse' }}>
                <thead>
                  <tr className="border-b border-border bg-input">
                    {['Visitor Name', 'Purpose', 'Host Resident', 'Unit', 'Arrival', 'Departure', 'Method', 'Status'].map((col, i) => (
                      <th key={i} className="px-4 py-3 text-left">
                        <div className="flex items-center gap-1">
                          <span className="text-xs font-semibold text-muted-foreground font-body uppercase tracking-wide">{col}</span>
                          {i < 7 && <Icon i="chevrons-up-down" size={11} className="text-muted-foreground" />}
                        </div>
                      </th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {logTable.map((row, i) => {
                    const p = purposeMap[row.purpose] || purposeMap['Guest'];
                    return (
                      <tr key={i} className={`border-b border-border ${i % 2 === 0 ? 'bg-card' : 'bg-input'}`}>
                        <td className="px-4 py-3">
                          <span className="text-sm font-medium text-foreground font-body">{row.name}</span>
                        </td>
                        <td className="px-4 py-3">
                          <div className={`flex items-center gap-1.5 w-fit px-2 py-0.5 rounded-md ${p.bg}`}>
                            <Icon i={p.icon} size={11} className={p.color} />
                            <span className={`text-xs font-medium font-body ${p.color}`}>{row.purpose}</span>
                          </div>
                        </td>
                        <td className="px-4 py-3">
                          <span className="text-sm text-foreground font-body">{row.host}</span>
                        </td>
                        <td className="px-4 py-3">
                          <span className="text-sm font-medium text-muted-foreground font-body">{row.unit}</span>
                        </td>
                        <td className="px-4 py-3">
                          <span className="text-sm text-muted-foreground font-body">{row.arrival}</span>
                        </td>
                        <td className="px-4 py-3">
                          <span className="text-sm text-muted-foreground font-body">{row.departure}</span>
                        </td>
                        <td className="px-4 py-3">
                          <span className="text-xs font-medium text-muted-foreground font-body bg-muted px-2 py-0.5 rounded-md">{row.method}</span>
                        </td>
                        <td className="px-4 py-3">
                          <span className={`text-xs font-semibold font-body px-2 py-1 rounded-md ${statusStyle[row.status]}`}>{row.status}</span>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </div>

        </div>
      </div>
    </div>
  );
}
