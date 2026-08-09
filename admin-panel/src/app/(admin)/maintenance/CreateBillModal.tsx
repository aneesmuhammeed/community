'use client'

import React, { useState } from 'react';
import styles from './maintenance.module.css';
import { createBillingCycle } from './actions';

type CreateBillModalProps = {
  onClose: () => void;
};

export default function CreateBillModal({ onClose }: CreateBillModalProps) {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsSubmitting(true);
    setError('');

    const formData = new FormData(e.currentTarget);
    const result = await createBillingCycle(formData);

    if (result.error) {
      setError(result.error);
      setIsSubmitting(false);
    } else {
      onClose();
    }
  };

  return (
    <div className={styles.modalOverlay} onClick={onClose}>
      <div className={styles.modalContent} onClick={(e) => e.stopPropagation()}>
        <div className={styles.modalHeader}>
          <h2 className={styles.modalTitle}>Create Billing Cycle</h2>
          <button className={styles.closeBtn} onClick={onClose}>&times;</button>
        </div>

        <form onSubmit={handleSubmit}>
          {error && <div className={styles.errorText}>{error}</div>}

          <div className={styles.formGroup}>
            <label className={styles.label} htmlFor="billingMonth">Billing Month</label>
            <input
              type="text"
              id="billingMonth"
              name="billingMonth"
              className={styles.input}
              placeholder="e.g., January 2025"
              required
            />
          </div>

          <div className={styles.formGroup}>
            <label className={styles.label} htmlFor="totalAmount">Total Amount (₹)</label>
            <input
              type="number"
              id="totalAmount"
              name="totalAmount"
              className={styles.input}
              placeholder="e.g., 3500"
              min="0"
              step="0.01"
              required
            />
          </div>

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

          <div className={styles.modalActions}>
            <button type="button" className={styles.cancelBtn} onClick={onClose} disabled={isSubmitting}>
              Cancel
            </button>
            <button type="submit" className={styles.primaryBtn} disabled={isSubmitting}>
              {isSubmitting ? 'Creating...' : 'Create Bill'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
