'use client'

import React, { useState } from 'react';
import { updateComplaintStatus } from './actions';

type Complaint = {
  id: string;
  title: string;
  description: string;
  category: string;
  priority: string;
  status: string;
  created_at: string;
};

const formatDate = (dateStr: string) => {
  return new Date(dateStr).toLocaleDateString('en-US', {
    month: 'short', day: 'numeric', year: 'numeric'
  });
};

export default function ComplaintsClient({ initialData }: { initialData: Complaint[] }) {
  const [processingId, setProcessingId] = useState<string | null>(null);

  const handleStatusChange = async (id: string, newStatus: string) => {
    setProcessingId(id);
    try {
      await updateComplaintStatus(id, newStatus);
    } catch (e) {
      alert('Failed to update status');
    } finally {
      setProcessingId(null);
    }
  };

  return (
    <div style={{ padding: '24px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '24px' }}>
        <div>
          <h1 style={{ fontSize: '24px', fontWeight: 'bold' }}>Complaints & Tickets</h1>
          <p style={{ color: 'var(--text-secondary)' }}>Manage and resolve resident issues.</p>
        </div>
      </div>

      {initialData.length === 0 ? (
        <div style={{ padding: '40px', textAlign: 'center', background: 'white', borderRadius: '8px' }}>
          <h3>No complaints found</h3>
        </div>
      ) : (
        <div style={{ background: 'white', borderRadius: '8px', overflow: 'hidden', border: '1px solid #e2e8f0' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
            <thead style={{ background: '#f8fafc', borderBottom: '1px solid #e2e8f0' }}>
              <tr>
                <th style={{ padding: '12px 16px', fontWeight: '500', color: '#64748b' }}>Date</th>
                <th style={{ padding: '12px 16px', fontWeight: '500', color: '#64748b' }}>Title</th>
                <th style={{ padding: '12px 16px', fontWeight: '500', color: '#64748b' }}>Category</th>
                <th style={{ padding: '12px 16px', fontWeight: '500', color: '#64748b' }}>Priority</th>
                <th style={{ padding: '12px 16px', fontWeight: '500', color: '#64748b' }}>Status</th>
              </tr>
            </thead>
            <tbody>
              {initialData.map((c) => (
                <tr key={c.id} style={{ borderBottom: '1px solid #e2e8f0' }}>
                  <td style={{ padding: '12px 16px', color: '#475569' }}>{formatDate(c.created_at)}</td>
                  <td style={{ padding: '12px 16px' }}>
                    <div style={{ fontWeight: '500', color: '#0f172a' }}>{c.title}</div>
                    <div style={{ fontSize: '0.85rem', color: '#64748b', marginTop: '4px' }}>{c.description}</div>
                  </td>
                  <td style={{ padding: '12px 16px', textTransform: 'capitalize' }}>{c.category}</td>
                  <td style={{ padding: '12px 16px', textTransform: 'capitalize' }}>
                    <span style={{ 
                      padding: '4px 8px', 
                      borderRadius: '4px', 
                      fontSize: '0.8rem',
                      background: c.priority === 'high' ? '#fee2e2' : c.priority === 'medium' ? '#fef9c3' : '#f1f5f9',
                      color: c.priority === 'high' ? '#b91c1c' : c.priority === 'medium' ? '#854d0e' : '#475569'
                    }}>
                      {c.priority}
                    </span>
                  </td>
                  <td style={{ padding: '12px 16px' }}>
                    <select 
                      value={c.status} 
                      onChange={(e) => handleStatusChange(c.id, e.target.value)}
                      disabled={processingId === c.id}
                      style={{ 
                        padding: '6px 12px', 
                        borderRadius: '6px', 
                        border: '1px solid #cbd5e1',
                        background: c.status === 'resolved' ? '#dcfce7' : c.status === 'in_progress' ? '#dbeafe' : 'white',
                        color: c.status === 'resolved' ? '#15803d' : c.status === 'in_progress' ? '#1d4ed8' : '#334155'
                      }}
                    >
                      <option value="open">Open</option>
                      <option value="in_progress">In Progress</option>
                      <option value="resolved">Resolved</option>
                      <option value="closed">Closed</option>
                    </select>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
