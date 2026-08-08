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
  const [selectedAnnouncement, setSelectedAnnouncement] = useState<Announcement | null>(null);

  const handleDelete = async (id: string) => {
    if (!confirm('Are you sure you want to delete this announcement?')) return;
    setIsProcessingId(id);
    await deleteAnnouncement(id);
    setIsProcessingId(null);
    // Close popup if the deleted item was open
    if (selectedAnnouncement?.id === id) setSelectedAnnouncement(null);
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

  const formatFullDate = (isoStr: string) => {
    return new Date(isoStr).toLocaleDateString('en-US', {
      weekday: 'long', month: 'long', day: 'numeric', year: 'numeric',
      hour: 'numeric', minute: '2-digit'
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
          <p>Click &quot;Create Announcement&quot; to post your first update to the community.</p>
        </div>
      ) : (
        <div className={styles.grid}>
          {initialData.map((item) => (
            <div
              key={item.id}
              className={`${styles.card} ${item.is_pinned ? styles.cardPinned : ''}`}
              onClick={() => setSelectedAnnouncement(item)}
              role="button"
              tabIndex={0}
              onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') setSelectedAnnouncement(item); }}
            >
              <div className={styles.cardHeader}>
                <span className={styles.tagBadge}>{item.tag}</span>
                <div className={styles.cardActions} onClick={(e) => e.stopPropagation()}>
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
              <p className={`${styles.cardBody} ${styles.cardBodyTruncated}`}>{item.body}</p>
              <div className={styles.cardFooter}>
                <span>Posted on {formatDate(item.created_at)}</span>
                <span className={styles.readMore}>Read more →</span>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Detail Popup */}
      {selectedAnnouncement && (
        <div className={styles.modalOverlay} onClick={() => setSelectedAnnouncement(null)}>
          <div className={styles.detailPopup} onClick={(e) => e.stopPropagation()}>
            <div className={styles.modalHeader}>
              <div className={styles.detailHeaderLeft}>
                <span className={styles.tagBadge}>{selectedAnnouncement.tag}</span>
                {selectedAnnouncement.is_pinned && <span className={styles.pinnedBadge}>📌 Pinned</span>}
              </div>
              <button className={styles.closeBtn} onClick={() => setSelectedAnnouncement(null)}>&times;</button>
            </div>
            <h2 className={styles.detailTitle}>{selectedAnnouncement.title}</h2>
            <p className={styles.detailDate}>{formatFullDate(selectedAnnouncement.created_at)}</p>
            <div className={styles.detailDivider} />
            <p className={styles.detailBody}>{selectedAnnouncement.body}</p>
            <div className={styles.detailActions}>
              <button
                className={`${styles.iconBtn} ${selectedAnnouncement.is_pinned ? styles.pinActive : ''}`}
                onClick={() => handleTogglePin(selectedAnnouncement.id, selectedAnnouncement.is_pinned)}
                disabled={isProcessingId === selectedAnnouncement.id}
              >
                📍 {selectedAnnouncement.is_pinned ? 'Unpin' : 'Pin'}
              </button>
              <button
                className={`${styles.iconBtn} ${styles.deleteBtn}`}
                onClick={() => handleDelete(selectedAnnouncement.id)}
                disabled={isProcessingId === selectedAnnouncement.id}
              >
                🗑️ Delete
              </button>
            </div>
          </div>
        </div>
      )}

      {isModalOpen && <CreateAnnouncementModal onClose={() => setIsModalOpen(false)} />}
    </div>
  );
}
