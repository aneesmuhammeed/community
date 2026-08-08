'use client'

import React, { useState } from 'react';
import styles from './announcements.module.css';
import { createAnnouncement } from './actions';

export default function CreateAnnouncementModal({ onClose }: { onClose: () => void }) {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setIsSubmitting(true);
    setErrorMsg(null);

    const formData = new FormData(e.currentTarget);
    const res = await createAnnouncement(formData);

    if (res.error) {
      setErrorMsg(res.error);
      setIsSubmitting(false);
    } else {
      onClose();
    }
  };

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modalContent}>
        <div className={styles.modalHeader}>
          <h2 className={styles.modalTitle}>New Announcement</h2>
          <button className={styles.closeBtn} onClick={onClose}>&times;</button>
        </div>

        {errorMsg && (
          <div style={{ color: '#ef4444', marginBottom: '16px', fontSize: '14px' }}>
            {errorMsg}
          </div>
        )}

        <form onSubmit={handleSubmit}>
          <div className={styles.formGroup}>
            <label className={styles.label}>Title</label>
            <input name="title" className={styles.input} required placeholder="e.g. Water Supply Interruption" />
          </div>

          <div className={styles.formGroup}>
            <label className={styles.label}>Message</label>
            <textarea name="body" className={styles.textarea} required placeholder="Details about the announcement..." />
          </div>

          <div className={styles.formGroup}>
            <label className={styles.label}>Tag</label>
            <select name="tag" className={styles.select} required>
              <option value="general">General</option>
              <option value="maintenance">Maintenance</option>
              <option value="event">Event</option>
              <option value="alert">Alert</option>
              <option value="security">Security</option>
            </select>
          </div>

          <div className={styles.formGroup}>
            <label className={styles.label}>Icon</label>
            <select name="icon" className={styles.select} defaultValue="info">
              <option value="megaphone">Megaphone (Announcement)</option>
              <option value="info">Info (Information)</option>
              <option value="bell">Bell (Notification)</option>
              <option value="alert-triangle">Alert Triangle (Warning)</option>
              <option value="droplets">Droplets (Water Supply)</option>
              <option value="zap">Lightning (Power/Electricity)</option>
              <option value="wrench">Wrench (Maintenance)</option>
              <option value="calendar">Calendar (Event)</option>
              <option value="shield">Shield (Security)</option>
            </select>
          </div>

          <div className={styles.checkboxGroup}>
            <input type="checkbox" id="is_pinned" name="is_pinned" value="true" />
            <label htmlFor="is_pinned" style={{ fontSize: '14px', color: '#475569' }}>
              Pin this announcement to the top
            </label>
          </div>

          <div className={styles.modalActions}>
            <button type="button" className={styles.cancelBtn} onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className={styles.primaryBtn} disabled={isSubmitting}>
              {isSubmitting ? 'Posting...' : 'Post Announcement'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
