'use client'

import React, { useState } from 'react';
import styles from './announcements.module.css';
import CreateAnnouncementModal from './CreateAnnouncementModal';
import { deleteAnnouncement, togglePinAnnouncement } from './actions';

type Announcement = {
  id: string;
  title: string;
  body: string;
  tag: string;
  is_pinned: boolean;
  created_at: string;
};

export default function AnnouncementsClient({ initialData }: { initialData: Announcement[] }) {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isProcessingId, setIsProcessingId] = useState<string | null>(null);

  const handleDelete = async (id: string) => {
    if (!confirm('Are you sure you want to delete this announcement?')) return;
    setIsProcessingId(id);
    await deleteAnnouncement(id);
    setIsProcessingId(null);
  };

  const handleTogglePin = async (id: string, currentStatus: boolean) => {
    setIsProcessingId(id);
    await togglePinAnnouncement(id, currentStatus);
    setIsProcessingId(null);
  };

  const formatDate = (isoStr: string) => {
    return new Date(isoStr).toLocaleDateString('en-US', {
      month: 'short', day: 'numeric', year: 'numeric'
    });
  };

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <h1 className={styles.title}>Community Announcements</h1>
        <button className={styles.primaryBtn} onClick={() => setIsModalOpen(true)}>
          <span style={{ fontSize: '18px' }}>+</span> Create Announcement
        </button>
      </div>

      {initialData.length === 0 ? (
        <div className={styles.emptyState}>
          <h3>No announcements yet</h3>
          <p>Click "Create Announcement" to post your first update to the community.</p>
        </div>
      ) : (
        <div className={styles.grid}>
          {initialData.map((item) => (
            <div key={item.id} className={`${styles.card} ${item.is_pinned ? styles.cardPinned : ''}`}>
              <div className={styles.cardHeader}>
                <span className={styles.tagBadge}>{item.tag}</span>
                <div className={styles.cardActions}>
                  <button 
                    className={`${styles.iconBtn} ${item.is_pinned ? styles.pinActive : ''}`} 
                    onClick={() => handleTogglePin(item.id, item.is_pinned)}
                    title={item.is_pinned ? "Unpin" : "Pin to top"}
                    disabled={isProcessingId === item.id}
                  >
                    📍
                  </button>
                  <button 
                    className={`${styles.iconBtn} ${styles.deleteBtn}`} 
                    onClick={() => handleDelete(item.id)}
                    title="Delete"
                    disabled={isProcessingId === item.id}
                  >
                    🗑️
                  </button>
                </div>
              </div>
              <h3 className={styles.cardTitle}>{item.title}</h3>
              <p className={styles.cardBody}>{item.body}</p>
              <div className={styles.cardFooter}>
                <span>Posted on {formatDate(item.created_at)}</span>
              </div>
            </div>
          ))}
        </div>
      )}

      {isModalOpen && <CreateAnnouncementModal onClose={() => setIsModalOpen(false)} />}
    </div>
  );
}
