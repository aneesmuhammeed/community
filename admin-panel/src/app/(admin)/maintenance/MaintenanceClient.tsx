'use client'

import React, { useState } from 'react';
import styles from './maintenance.module.css';
import CreateBillModal from './CreateBillModal';
import { deleteBillingCycle } from './actions';

type BillingCycle = {
  id: string;
  apartment_id: string;
  billing_month: string;
  total_amount: number;
  due_date: string;
  status: string;
};

const formatDate = (dateStr: string) => {
  return new Date(dateStr).toLocaleDateString('en-US', {
    month: 'short', day: 'numeric', year: 'numeric'
  });
};

const getStatusClass = (status: string) => {
  switch (status.toLowerCase()) {
    case 'paid': return styles.statusPaid;
    case 'overdue': return styles.statusOverdue;
    case 'pending':
    default: return styles.statusPending;
  }
};

export default function MaintenanceClient({ initialData }: { initialData: BillingCycle[] }) {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isProcessingId, setIsProcessingId] = useState<string | null>(null);

  const handleDelete = async (id: string) => {
    if (!confirm('Are you sure you want to delete this billing cycle?')) return;
    setIsProcessingId(id);
    try {
      await deleteBillingCycle(id);
    } catch (e) {
      alert('Failed to delete billing cycle');
    } finally {
      setIsProcessingId(null);
    }
  };

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <h1 className={styles.title}>Maintenance & Billing</h1>
        <button className={styles.primaryBtn} onClick={() => setIsModalOpen(true)}>
          <span style={{ fontSize: '18px' }}>+</span> Create Bill
        </button>
      </div>

      {initialData.length === 0 ? (
        <div className={styles.emptyState}>
          <h3>No billing cycles found</h3>
          <p>Click &quot;Create Bill&quot; to generate the first maintenance bill.</p>
        </div>
      ) : (
        <div className={styles.tableContainer}>
          <table className={styles.table}>
            <thead>
              <tr>
                <th>Billing Month</th>
                <th>Total Amount</th>
                <th>Due Date</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {initialData.map((bill) => (
                <tr key={bill.id}>
                  <td>{bill.billing_month}</td>
                  <td>₹{bill.total_amount}</td>
                  <td>{formatDate(bill.due_date)}</td>
                  <td>
                    <span className={`${styles.statusBadge} ${getStatusClass(bill.status)}`}>
                      {bill.status}
                    </span>
                  </td>
                  <td>
                    <button
                      className={`${styles.iconBtn} ${styles.deleteBtn}`}
                      onClick={() => handleDelete(bill.id)}
                      title="Delete"
                      disabled={isProcessingId === bill.id}
                    >
                      🗑️
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {isModalOpen && <CreateBillModal onClose={() => setIsModalOpen(false)} />}
    </div>
  );
}
