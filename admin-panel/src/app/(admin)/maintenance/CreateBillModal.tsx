'use client'

import React, { useState, useEffect } from 'react';
import styles from './maintenance.module.css';
import { createBillingCycle, getApartments } from './actions';

type Apartment = {
  id: string;
  unit_number: string;
  floor: number | null;
  block_name: string;
};

type CreateBillModalProps = {
  onClose: () => void;
  apartments: Apartment[];
};

export default function CreateBillModal({ onClose, apartments }: CreateBillModalProps) {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');

  // Itemized amounts
  const [baseAmount, setBaseAmount] = useState('');
  const [electricity, setElectricity] = useState('');
  const [water, setWater] = useState('');
  const [housekeeping, setHousekeeping] = useState('');
  const [security, setSecurity] = useState('');
  const [repairs, setRepairs] = useState('');
  const [miscellaneous, setMiscellaneous] = useState('');

  const totalAmount =
    (parseFloat(baseAmount) || 0) +
    (parseFloat(electricity) || 0) +
    (parseFloat(water) || 0) +
    (parseFloat(housekeeping) || 0) +
    (parseFloat(security) || 0) +
    (parseFloat(repairs) || 0) +
    (parseFloat(miscellaneous) || 0);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsSubmitting(true);
    setError('');

    const formData = new FormData(e.currentTarget);
    // Ensure amounts are set from state
    formData.set('baseAmount', baseAmount || '0');
    formData.set('electricity', electricity || '0');
    formData.set('water', water || '0');
    formData.set('housekeeping', housekeeping || '0');
    formData.set('security', security || '0');
    formData.set('repairs', repairs || '0');
    formData.set('miscellaneous', miscellaneous || '0');

    const result = await createBillingCycle(formData);

    if (result.error) {
      setError(result.error);
      setIsSubmitting(false);
    } else {
      onClose();
    }
  };

  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  return (
    <div className={styles.modalOverlay} onClick={onClose}>
      <div className={styles.modalContent} onClick={(e) => e.stopPropagation()}>
        <div className={styles.modalHeader}>
          <h2 className={styles.modalTitle}>Create Billing Cycle</h2>
          <button className={styles.closeBtn} onClick={onClose}>&times;</button>
        </div>

        <form onSubmit={handleSubmit}>
          {error && <div className={styles.errorText}>{error}</div>}

          {/* Apartment Selector */}
          <div className={styles.formGroup}>
            <label className={styles.label} htmlFor="apartmentId">Apartment</label>
            <select
              id="apartmentId"
              name="apartmentId"
              className={styles.input}
              required
            >
              <option value="">Select apartment…</option>
              {apartments.map((apt) => (
                <option key={apt.id} value={apt.id}>
                  {apt.block_name} — {apt.unit_number}
                </option>
              ))}
            </select>
          </div>

          {/* Billing Month */}
          <div className={styles.formGroup}>
            <label className={styles.label} htmlFor="billingMonth">Billing Month</label>
            <select
              id="billingMonth"
              name="billingMonth"
              className={styles.input}
              required
            >
              <option value="">Select month…</option>
              {months.map((m) => (
                <option key={m} value={m}>{m}</option>
              ))}
            </select>
          </div>

          {/* Due Date */}
          <div className={styles.formGroup}>
            <label className={styles.label} htmlFor="dueDate">Due Date</label>
            <input
              type="date"
              id="dueDate"
              name="dueDate"
              className={styles.input}
              required
            />
          </div>

          {/* Itemized Breakdown */}
          <div className={styles.breakdownSection}>
            <h3 className={styles.breakdownTitle}>Expense Breakdown</h3>
            <div className={styles.breakdownGrid}>
              <div className={styles.breakdownField}>
                <label className={styles.label}>Base Amount (₹)</label>
                <input type="number" name="baseAmount" className={styles.input} placeholder="0" min="0" step="0.01" value={baseAmount} onChange={(e) => setBaseAmount(e.target.value)} />
              </div>
              <div className={styles.breakdownField}>
                <label className={styles.label}>Electricity (₹)</label>
                <input type="number" name="electricity" className={styles.input} placeholder="0" min="0" step="0.01" value={electricity} onChange={(e) => setElectricity(e.target.value)} />
              </div>
              <div className={styles.breakdownField}>
                <label className={styles.label}>Water (₹)</label>
                <input type="number" name="water" className={styles.input} placeholder="0" min="0" step="0.01" value={water} onChange={(e) => setWater(e.target.value)} />
              </div>
              <div className={styles.breakdownField}>
                <label className={styles.label}>Housekeeping (₹)</label>
                <input type="number" name="housekeeping" className={styles.input} placeholder="0" min="0" step="0.01" value={housekeeping} onChange={(e) => setHousekeeping(e.target.value)} />
              </div>
              <div className={styles.breakdownField}>
                <label className={styles.label}>Security (₹)</label>
                <input type="number" name="security" className={styles.input} placeholder="0" min="0" step="0.01" value={security} onChange={(e) => setSecurity(e.target.value)} />
              </div>
              <div className={styles.breakdownField}>
                <label className={styles.label}>Repairs (₹)</label>
                <input type="number" name="repairs" className={styles.input} placeholder="0" min="0" step="0.01" value={repairs} onChange={(e) => setRepairs(e.target.value)} />
              </div>
              <div className={styles.breakdownField}>
                <label className={styles.label}>Miscellaneous (₹)</label>
                <input type="number" name="miscellaneous" className={styles.input} placeholder="0" min="0" step="0.01" value={miscellaneous} onChange={(e) => setMiscellaneous(e.target.value)} />
              </div>
            </div>
            <div className={styles.totalRow}>
              <span>Total Amount</span>
              <span className={styles.totalAmount}>₹{totalAmount.toLocaleString('en-IN', { minimumFractionDigits: 0 })}</span>
            </div>
          </div>

          <div className={styles.modalActions}>
            <button type="button" className={styles.cancelBtn} onClick={onClose} disabled={isSubmitting}>
              Cancel
            </button>
            <button type="submit" className={styles.primaryBtn} disabled={isSubmitting || totalAmount <= 0}>
              {isSubmitting ? 'Creating...' : 'Create Bill'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
