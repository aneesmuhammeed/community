'use client'

import React, { useState } from 'react';
import styles from './maintenance.module.css';
import CreateBillModal from './CreateBillModal';
import { deleteBillingCycle, markAsPaid } from './actions';

type Apartment = {
  id: string;
  unit_number: string;
  floor: number | null;
  block_name: string;
};

type BillingCycle = {
  id: string;
  apartment_id: string;
  billing_month: string;
  billing_year: number;
  base_amount: number;
  electricity: number;
  water: number;
  housekeeping: number;
  security: number;
  repairs: number;
  miscellaneous: number;
  total_amount: number;
  due_date: string;
  paid_at: string | null;
  paid_amount: number | null;
  status: string;
  unit_number: string;
  block_name: string;
};

type Transaction = {
  id: string;
  amount: number;
  method: string;
  method_label: string | null;
  reference_no: string;
  status: string;
  created_at: string;
  completed_at: string | null;
  billing_cycles: { billing_month: string; billing_year: number } | null;
};

type BillingSummary = {
  totalCollected: number;
  totalPending: number;
  overdueCount: number;
};

type Props = {
  initialData: BillingCycle[];
  apartments: Apartment[];
  summary: BillingSummary;
  transactions: Transaction[];
};

const formatDate = (dateStr: string) => {
  return new Date(dateStr).toLocaleDateString('en-US', {
    month: 'short', day: 'numeric', year: 'numeric'
  });
};

const formatCurrency = (amt: number) => {
  return '₹' + amt.toLocaleString('en-IN');
};

const getStatusClass = (status: string) => {
  switch (status.toLowerCase()) {
    case 'paid': case 'success': return styles.statusPaid;
    case 'overdue': case 'failed': return styles.statusOverdue;
    case 'pending':
    default: return styles.statusPending;
  }
};

export default function MaintenanceClient({ initialData, apartments, summary, transactions }: Props) {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isProcessingId, setIsProcessingId] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<'billing' | 'transactions'>('billing');
  const [filterApartment, setFilterApartment] = useState('');

  const filteredBills = filterApartment
    ? initialData.filter((b) => b.apartment_id === filterApartment)
    : initialData;

  const handleDelete = async (id: string) => {
    if (!confirm('Are you sure you want to delete this billing cycle?')) return;
    setIsProcessingId(id);
    try {
      await deleteBillingCycle(id);
    } catch {
      alert('Failed to delete billing cycle');
    } finally {
      setIsProcessingId(null);
    }
  };

  const handleMarkPaid = async (id: string) => {
    if (!confirm('Mark this bill as paid?')) return;
    setIsProcessingId(id);
    try {
      const result = await markAsPaid(id);
      if (result.error) alert(result.error);
    } catch {
      alert('Failed to mark as paid');
    } finally {
      setIsProcessingId(null);
    }
  };

  return (
    <div className={styles.container}>
      {/* ─── Header ─── */}
      <div className={styles.header}>
        <h1 className={styles.title}>Maintenance &amp; Billing</h1>
        <button className={styles.primaryBtn} onClick={() => setIsModalOpen(true)}>
          <span style={{ fontSize: '18px' }}>+</span> Create Bill
        </button>
      </div>

      {/* ─── Summary Cards ─── */}
      <div className={styles.summaryRow}>
        <div className={`${styles.summaryCard} ${styles.summaryCollected}`}>
          <span className={styles.summaryLabel}>Collected (This Year)</span>
          <span className={styles.summaryValue}>{formatCurrency(summary.totalCollected)}</span>
        </div>
        <div className={`${styles.summaryCard} ${styles.summaryPending}`}>
          <span className={styles.summaryLabel}>Total Pending</span>
          <span className={styles.summaryValue}>{formatCurrency(summary.totalPending)}</span>
        </div>
        <div className={`${styles.summaryCard} ${styles.summaryOverdue}`}>
          <span className={styles.summaryLabel}>Overdue Bills</span>
          <span className={styles.summaryValue}>{summary.overdueCount}</span>
        </div>
      </div>

      {/* ─── Tabs ─── */}
      <div className={styles.tabs}>
        <button
          className={`${styles.tab} ${activeTab === 'billing' ? styles.tabActive : ''}`}
          onClick={() => setActiveTab('billing')}
        >
          Billing Cycles
        </button>
        <button
          className={`${styles.tab} ${activeTab === 'transactions' ? styles.tabActive : ''}`}
          onClick={() => setActiveTab('transactions')}
        >
          Transactions
        </button>
      </div>

      {/* ─── Billing Cycles Tab ─── */}
      {activeTab === 'billing' && (
        <>
          {/* Apartment Filter */}
          <div className={styles.filterRow}>
            <select
              className={styles.filterSelect}
              value={filterApartment}
              onChange={(e) => setFilterApartment(e.target.value)}
            >
              <option value="">All Apartments</option>
              {apartments.map((apt) => (
                <option key={apt.id} value={apt.id}>
                  {apt.block_name} — {apt.unit_number}
                </option>
              ))}
            </select>
          </div>

          {filteredBills.length === 0 ? (
            <div className={styles.emptyState}>
              <h3>No billing cycles found</h3>
              <p>Click &quot;Create Bill&quot; to generate the first maintenance bill.</p>
            </div>
          ) : (
            <div className={styles.tableContainer}>
              <table className={styles.table}>
                <thead>
                  <tr>
                    <th>Apartment</th>
                    <th>Month</th>
                    <th>Base</th>
                    <th>Elec.</th>
                    <th>Water</th>
                    <th>HK</th>
                    <th>Total</th>
                    <th>Due Date</th>
                    <th>Status</th>
                    <th>Paid Date</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredBills.map((bill) => (
                    <tr key={bill.id}>
                      <td>
                        <span className={styles.apartmentCell}>
                          {bill.block_name} — {bill.unit_number}
                        </span>
                      </td>
                      <td>{bill.billing_month} {bill.billing_year}</td>
                      <td>{formatCurrency(bill.base_amount)}</td>
                      <td>{formatCurrency(bill.electricity)}</td>
                      <td>{formatCurrency(bill.water)}</td>
                      <td>{formatCurrency(bill.housekeeping)}</td>
                      <td><strong>{formatCurrency(bill.total_amount)}</strong></td>
                      <td>{formatDate(bill.due_date)}</td>
                      <td>
                        <span className={`${styles.statusBadge} ${getStatusClass(bill.status)}`}>
                          {bill.status}
                        </span>
                      </td>
                      <td>{bill.paid_at ? formatDate(bill.paid_at) : '—'}</td>
                      <td>
                        <div className={styles.actionBtns}>
                          {bill.status !== 'paid' && (
                            <button
                              className={`${styles.iconBtn} ${styles.paidBtn}`}
                              onClick={() => handleMarkPaid(bill.id)}
                              title="Mark as Paid"
                              disabled={isProcessingId === bill.id}
                            >
                              ✓
                            </button>
                          )}
                          <button
                            className={`${styles.iconBtn} ${styles.deleteBtn}`}
                            onClick={() => handleDelete(bill.id)}
                            title="Delete"
                            disabled={isProcessingId === bill.id}
                          >
                            🗑️
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </>
      )}

      {/* ─── Transactions Tab ─── */}
      {activeTab === 'transactions' && (
        <>
          {transactions.length === 0 ? (
            <div className={styles.emptyState}>
              <h3>No transactions yet</h3>
              <p>Transactions will appear here once residents make payments.</p>
            </div>
          ) : (
            <div className={styles.tableContainer}>
              <table className={styles.table}>
                <thead>
                  <tr>
                    <th>Date</th>
                    <th>Billing Period</th>
                    <th>Amount</th>
                    <th>Method</th>
                    <th>Reference No</th>
                    <th>Status</th>
                  </tr>
                </thead>
                <tbody>
                  {transactions.map((txn) => (
                    <tr key={txn.id}>
                      <td>{formatDate(txn.created_at)}</td>
                      <td>
                        {txn.billing_cycles
                          ? `${txn.billing_cycles.billing_month} ${txn.billing_cycles.billing_year}`
                          : '—'}
                      </td>
                      <td><strong>{formatCurrency(txn.amount)}</strong></td>
                      <td>{txn.method_label || txn.method}</td>
                      <td><code className={styles.refNo}>{txn.reference_no}</code></td>
                      <td>
                        <span className={`${styles.statusBadge} ${getStatusClass(txn.status)}`}>
                          {txn.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </>
      )}

      {isModalOpen && <CreateBillModal onClose={() => setIsModalOpen(false)} apartments={apartments} />}
    </div>
  );
}
