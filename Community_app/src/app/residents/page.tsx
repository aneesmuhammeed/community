import React from 'react';
import Icon from '@/components/Icon';
import UserAvatar from '@/components/UserAvatar';
import AdminTopNav from '@/components/AdminTopNav';
import AdminSidebarResidents from '@/components/AdminSidebarResidents';
import ResidentDetailDrawer from '@/components/ResidentDetailDrawer';

const residents = [
  { name: 'Arjun Mehta', unit: 'C-403', type: 'Owner', phone: '+91 98765 43210', email: 'arjun.m@gmail.com', moveIn: 'Mar 2019', due: 'Paid', status: 'Active', gender: 'male', heritage: 'South Asian', idx: 0 },
  { name: 'Priya Nair', unit: 'B-207', type: 'Tenant', phone: '+91 97654 32109', email: 'priya.nair@gmail.com', moveIn: 'Aug 2021', due: 'Pending', status: 'Active', gender: 'female', heritage: 'South Asian', idx: 1 },
  { name: 'Rajesh Sharma', unit: 'C-301', type: 'Owner', phone: '+91 96543 21098', email: 'r.sharma@gmail.com', moveIn: 'Jan 2020', due: 'Paid', status: 'Active', gender: 'male', heritage: 'South Asian', idx: 2 },
  { name: 'Sneha Iyer', unit: 'A-101', type: 'Tenant', phone: '+91 95432 10987', email: 'sneha.iyer@yahoo.com', moveIn: 'Jun 2022', due: 'Overdue', status: 'Active', gender: 'female', heritage: 'South Asian', idx: 3 },
  { name: 'Omar Khan', unit: 'D-512', type: 'Owner', phone: '+91 94321 09876', email: 'o.khan@gmail.com', moveIn: 'Nov 2018', due: 'Paid', status: 'Active', gender: 'male', heritage: 'Middle Eastern', idx: 4 },
  { name: 'Meera Pillai', unit: 'A-205', type: 'Owner', phone: '+91 93210 98765', email: 'meera.p@gmail.com', moveIn: 'Apr 2021', due: 'Pending', status: 'Active', gender: 'female', heritage: 'South Asian', idx: 5 },
  { name: 'Vikram Desai', unit: 'B-312', type: 'Tenant', phone: '+91 92109 87654', email: 'v.desai@gmail.com', moveIn: 'Feb 2023', due: 'Paid', status: 'Inactive', gender: 'male', heritage: 'South Asian', idx: 6 },
  { name: 'Ananya Singh', unit: 'C-108', type: 'Owner', phone: '+91 91098 76543', email: 'ananya.s@gmail.com', moveIn: 'Sep 2017', due: 'Paid', status: 'Active', gender: 'female', heritage: 'South Asian', idx: 7 },
  { name: 'Rohan Gupta', unit: 'D-201', type: 'Tenant', phone: '+91 90987 65432', email: 'r.gupta@outlook.com', moveIn: 'Jul 2022', due: 'Overdue', status: 'Active', gender: 'male', heritage: 'South Asian', idx: 8 },
  { name: 'Kavitha Reddy', unit: 'B-410', type: 'Owner', phone: '+91 89876 54321', email: 'kavitha.r@gmail.com', moveIn: 'Dec 2019', due: 'Paid', status: 'Active', gender: 'female', heritage: 'South Asian', idx: 9 },
];

const dueStyle: Record<string, string> = {
  Paid: 'bg-accent-soft text-accent',
  Pending: 'bg-warning-soft text-warning-foreground',
  Overdue: 'bg-danger-soft text-danger',
};
const typeStyle: Record<string, string> = {
  Owner: 'bg-secondary text-secondary-foreground',
  Tenant: 'bg-muted text-muted-foreground',
};

const columns = ['Resident', 'Unit', 'Contact', 'Move-in', 'Due Status', 'Status', 'Actions'];

export default function ResidentsManagementScreen() {
  return (
    <div className="bg-input font-body flex flex-col" style={{ minHeight: '1020px' }}>
      <AdminTopNav />

      <div className="flex flex-1">
        <AdminSidebarResidents />

        {/* Main area */}
        <div className="flex-1 flex flex-col min-w-0">
          <div className="flex flex-1">
            {/* Content */}
            <div className="flex-1 px-8 py-7 flex flex-col gap-5 min-w-0">

              {/* Page Header */}
              <div className="flex items-start justify-between">
                <div>
                  <p className="text-xl font-semibold text-foreground font-body">Residents Management</p>
                  <p className="text-sm text-muted-foreground font-body mt-0.5">Maple Heights Residency · 248 Units</p>
                </div>
                <div className="flex items-center gap-2.5">
                  <button className="flex items-center gap-1.5 px-4 py-2 rounded-lg border border-border bg-card text-sm font-medium text-foreground font-body cursor-pointer" style={{ boxShadow: '0 1px 4px 0 rgba(30,40,80,0.05)' }}>
                    <Icon i="download" size={15} className="text-muted-foreground" />
                    Export CSV
                  </button>
                  <button className="flex items-center gap-1.5 px-4 py-2 rounded-lg bg-primary text-primary-foreground text-sm font-semibold font-body border-none cursor-pointer" style={{ boxShadow: '0 4px 12px 0 rgba(37,99,235,0.25)' }}>
                    <Icon i="plus" size={15} />
                    Add Resident
                  </button>
                </div>
              </div>

              {/* Summary Cards */}
              <div className="flex gap-4">
                {[
                  { label: 'Total Units', main: '248', subs: [{ k: 'Occupied', v: '231' }, { k: 'Vacant', v: '17' }], icon: 'building-2', color: 'text-primary', bg: 'bg-secondary' },
                  { label: 'Resident Types', main: '248', subs: [{ k: 'Owners', v: '189' }, { k: 'Tenants', v: '42' }, { k: 'Others', v: '17' }], icon: 'users', color: 'text-accent', bg: 'bg-accent-soft' },
                  { label: 'Verification', main: '248', subs: [{ k: 'Verified', v: '220' }, { k: 'Pending KYC', v: '28' }], icon: 'shield-check', color: 'text-warning-foreground', bg: 'bg-warning-soft' },
                ].map((c, i) => (
                  <div key={i} className="flex-1 bg-card border border-border rounded-xl p-4" style={{ boxShadow: '0 2px 8px 0 rgba(30,40,80,0.06)' }}>
                    <div className="flex items-center gap-2.5 mb-3">
                      <div className={`w-8 h-8 rounded-lg flex items-center justify-center ${c.bg}`}>
                        <Icon i={c.icon} size={16} className={c.color} />
                      </div>
                      <p className="text-sm font-semibold text-foreground font-body">{c.label}</p>
                    </div>
                    <div className="flex gap-4">
                      {c.subs.map((s, j) => (
                        <div key={j}>
                          <p className="text-xl font-semibold text-foreground font-body">{s.v}</p>
                          <p className="text-xs text-muted-foreground font-body">{s.k}</p>
                        </div>
                      ))}
                    </div>
                  </div>
                ))}
              </div>

              {/* Filter Bar */}
              <div className="flex items-center gap-3 flex-wrap">
                <div className="flex items-center gap-2 bg-card border border-border rounded-lg px-3 py-2.5" style={{ minWidth: '220px', boxShadow: '0 1px 4px 0 rgba(30,40,80,0.04)' }}>
                  <Icon i="search" size={15} className="text-muted-foreground flex-shrink-0" />
                  <span className="text-sm text-muted-foreground font-body">Search residents…</span>
                </div>
                {[
                  { label: 'Block', value: 'All Blocks' },
                  { label: 'Status', value: 'All Status' },
                  { label: 'Type', value: 'All Types' },
                ].map((f, i) => (
                  <div key={i} className="flex items-center gap-2 bg-card border border-border rounded-lg px-3 py-2.5" style={{ boxShadow: '0 1px 4px 0 rgba(30,40,80,0.04)' }}>
                    <span className="text-xs text-muted-foreground font-body font-medium">{f.label}:</span>
                    <span className="text-sm font-medium text-foreground font-body">{f.value}</span>
                    <Icon i="chevron-down" size={14} className="text-muted-foreground" />
                  </div>
                ))}
                {/* Active filter chip */}
                <div className="flex items-center gap-1.5 bg-secondary border border-primary rounded-lg px-3 py-2 text-xs font-medium text-primary font-body">
                  Block C
                  <button className="ml-0.5 border-none bg-transparent cursor-pointer flex items-center justify-center p-0">
                    <Icon i="x" size={12} className="text-primary" />
                  </button>
                </div>
              </div>

              {/* Table */}
              <div className="bg-card border border-border rounded-xl overflow-hidden" style={{ boxShadow: '0 2px 8px 0 rgba(30,40,80,0.06)' }}>
                <table className="w-full" style={{ borderCollapse: 'collapse' }}>
                  <thead>
                    <tr className="border-b border-border">
                      {columns.map((col, i) => (
                        <th key={i} className="px-4 py-3 text-left">
                          <div className="flex items-center gap-1">
                            <span className="text-xs font-semibold text-muted-foreground font-body uppercase tracking-wide">{col}</span>
                            {i < columns.length - 1 && <Icon i="chevrons-up-down" size={12} className="text-muted-foreground" />}
                          </div>
                        </th>
                      ))}
                    </tr>
                  </thead>
                  <tbody>
                    {residents.map((r, i) => (
                      <tr key={i} className={`border-b border-border ${i % 2 === 0 ? 'bg-card' : 'bg-input'}`}>
                        {/* Resident Name */}
                        <td className="px-4 py-3">
                          <div className="flex items-center gap-3">
                            <UserAvatar gender={r.gender} heritage={r.heritage} ageGroup="25-35" index={r.idx} className="w-8 h-8 rounded-full flex-shrink-0" />
                            <div>
                              <p className="text-sm font-medium text-foreground font-body">{r.name}</p>
                              <span className={`text-xs font-medium font-body px-1.5 py-0.5 rounded-sm ${typeStyle[r.type]}`}>{r.type}</span>
                            </div>
                          </div>
                        </td>
                        {/* Unit */}
                        <td className="px-4 py-3">
                          <span className="text-sm text-foreground font-body font-medium">{r.unit}</span>
                        </td>
                        {/* Contact */}
                        <td className="px-4 py-3">
                          <p className="text-xs text-foreground font-body">{r.phone}</p>
                          <p className="text-xs text-muted-foreground font-body mt-0.5">{r.email}</p>
                        </td>
                        {/* Move-in */}
                        <td className="px-4 py-3">
                          <span className="text-sm text-muted-foreground font-body">{r.moveIn}</span>
                        </td>
                        {/* Due Status */}
                        <td className="px-4 py-3">
                          <span className={`text-xs font-semibold font-body px-2 py-1 rounded-md ${dueStyle[r.due]}`}>{r.due}</span>
                        </td>
                        {/* Status */}
                        <td className="px-4 py-3">
                          <div className="flex items-center gap-1.5">
                            <span className={`w-1.5 h-1.5 rounded-full ${r.status === 'Active' ? 'bg-accent' : 'bg-muted-foreground'}`}></span>
                            <span className={`text-xs font-medium font-body ${r.status === 'Active' ? 'text-accent' : 'text-muted-foreground'}`}>{r.status}</span>
                          </div>
                        </td>
                        {/* Actions */}
                        <td className="px-4 py-3">
                          <div className="flex items-center gap-1.5">
                            {[
                              { icon: 'eye', title: 'View' },
                              { icon: 'pencil', title: 'Edit' },
                              { icon: 'message-square', title: 'Message' },
                              { icon: 'user-x', title: 'Deactivate' },
                            ].map((a, j) => (
                              <button key={j} className="w-7 h-7 rounded-lg bg-muted flex items-center justify-center border-none cursor-pointer" title={a.title}>
                                <Icon i={a.icon} size={13} className="text-muted-foreground" />
                              </button>
                            ))}
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>

                {/* Pagination */}
                <div className="px-5 py-3 flex items-center justify-between border-t border-border">
                  <p className="text-xs text-muted-foreground font-body">Showing 1–10 of 248 residents</p>
                  <div className="flex items-center gap-1.5">
                    <button className="w-8 h-8 rounded-lg bg-muted flex items-center justify-center border-none cursor-pointer">
                      <Icon i="chevron-left" size={14} className="text-muted-foreground" />
                    </button>
                    {[1, 2, 3, '…', 25].map((p, i) => (
                      <button key={i} className={`w-8 h-8 rounded-lg text-xs font-medium font-body border-none cursor-pointer ${p === 1 ? 'bg-primary text-primary-foreground' : 'bg-muted text-muted-foreground'}`}>
                        {p}
                      </button>
                    ))}
                    <button className="w-8 h-8 rounded-lg bg-muted flex items-center justify-center border-none cursor-pointer">
                      <Icon i="chevron-right" size={14} className="text-muted-foreground" />
                    </button>
                  </div>
                </div>
              </div>

            </div>

            {/* Detail Drawer */}
            <ResidentDetailDrawer />
          </div>
        </div>
      </div>
    </div>
  );
}
