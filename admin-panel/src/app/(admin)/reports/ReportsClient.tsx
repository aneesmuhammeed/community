'use client'

import React from 'react';

type ReportsData = {
  complaints: { open: number, resolved: number, total: number };
  visitors: { active: number, completed: number, total: number };
  bookings: { confirmed: number, pending: number, total: number };
};

export default function ReportsClient({ data }: { data: ReportsData | null }) {
  if (!data) {
    return (
      <div style={{ padding: '24px' }}>
        <h1 style={{ fontSize: '24px', fontWeight: 'bold' }}>Reports & Analytics</h1>
        <p style={{ color: 'var(--text-secondary)' }}>Unable to load reports data.</p>
      </div>
    );
  }

  const { complaints, visitors, bookings } = data;

  const getPercentage = (part: number, total: number) => {
    if (total === 0) return 0;
    return Math.round((part / total) * 100);
  };

  const MetricCard = ({ title, primaryValue, secondaryValue, label1, label2, color1, color2, progress1, progress2 }: any) => (
    <div style={{
      background: 'white',
      borderRadius: '12px',
      padding: '24px',
      border: '1px solid #e2e8f0',
      boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.05)'
    }}>
      <h3 style={{ fontSize: '1rem', fontWeight: '600', color: '#475569', marginBottom: '16px' }}>{title}</h3>
      
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '24px' }}>
        <div>
          <div style={{ fontSize: '2rem', fontWeight: 'bold', color: '#0f172a' }}>{primaryValue}</div>
          <div style={{ fontSize: '0.875rem', color: '#64748b' }}>{label1}</div>
        </div>
        <div style={{ textAlign: 'right' }}>
          <div style={{ fontSize: '1.5rem', fontWeight: '600', color: '#334155' }}>{secondaryValue}</div>
          <div style={{ fontSize: '0.875rem', color: '#64748b' }}>{label2}</div>
        </div>
      </div>

      <div style={{ display: 'flex', gap: '4px', height: '8px', borderRadius: '4px', overflow: 'hidden' }}>
        <div style={{ width: `${progress1}%`, background: color1, transition: 'width 1s ease-in-out' }}></div>
        <div style={{ width: `${progress2}%`, background: color2, transition: 'width 1s ease-in-out' }}></div>
      </div>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '8px', fontSize: '0.75rem', color: '#94a3b8' }}>
        <span style={{ color: color1, fontWeight: '500' }}>{progress1}% {label1}</span>
        <span style={{ color: color2, fontWeight: '500' }}>{progress2}% {label2}</span>
      </div>
    </div>
  );

  return (
    <div style={{ padding: '24px' }}>
      <div style={{ marginBottom: '32px', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: 'bold', color: '#0f172a' }}>Reports & Analytics</h1>
          <p style={{ color: '#64748b' }}>High-level overview of society activities.</p>
        </div>
        <div style={{ background: '#e0e7ff', color: '#4338ca', padding: '6px 12px', borderRadius: '20px', fontSize: '0.875rem', fontWeight: '500' }}>
          This Month
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '24px' }}>
        
        <MetricCard
          title="Visitors Activity"
          primaryValue={visitors.active}
          secondaryValue={visitors.completed}
          label1="Active Now"
          label2="Completed"
          color1="#3b82f6"
          color2="#e2e8f0"
          progress1={getPercentage(visitors.active, visitors.total)}
          progress2={getPercentage(visitors.completed, visitors.total)}
        />

        <MetricCard
          title="Complaints Resolution"
          primaryValue={complaints.resolved}
          secondaryValue={complaints.open}
          label1="Resolved"
          label2="Open"
          color1="#10b981"
          color2="#f43f5e"
          progress1={getPercentage(complaints.resolved, complaints.total)}
          progress2={getPercentage(complaints.open, complaints.total)}
        />

        <MetricCard
          title="Facility Bookings"
          primaryValue={bookings.confirmed}
          secondaryValue={bookings.pending}
          label1="Confirmed"
          label2="Pending"
          color1="#8b5cf6"
          color2="#f59e0b"
          progress1={getPercentage(bookings.confirmed, bookings.total)}
          progress2={getPercentage(bookings.pending, bookings.total)}
        />

      </div>
      
      <div style={{ marginTop: '24px', display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(300px, 1fr))', gap: '24px' }}>
        <MetricCard
          title="Financial Dues (Mock Data)"
          primaryValue="$12,450"
          secondaryValue="$3,200"
          label1="Collected"
          label2="Pending"
          color1="#10b981"
          color2="#ef4444"
          progress1={80}
          progress2={20}
        />
      </div>
    </div>
  );
}
