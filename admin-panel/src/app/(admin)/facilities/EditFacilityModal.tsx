'use client';

import { useState } from 'react';
import styles from './facilities.module.css';
import { updateFacilitySettings } from './actions';
import { Settings } from 'lucide-react';

export default function EditFacilityModal({ facility }: { facility: any }) {
  const [isOpen, setIsOpen] = useState(false);
  const [loading, setLoading] = useState(false);

  // Parse existing format like "06:00-22:00" or fallback
  const getInitialTimes = () => {
    const hours = facility.operating_hours || '';
    if (hours.includes('-') && hours.includes(':')) {
      const [start, end] = hours.split('-');
      return { start: start.trim(), end: end.trim() };
    }
    return { start: '06:00', end: '22:00' };
  };

  const initialTimes = getInitialTimes();
  const [openTime, setOpenTime] = useState(initialTimes.start);
  const [closeTime, setCloseTime] = useState(initialTimes.end);
  const [slotDuration, setSlotDuration] = useState(facility.slot_duration || 1);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    
    const formData = new FormData();
    formData.append('id', facility.id);
    formData.append('operating_hours', `${openTime}-${closeTime}`);
    formData.append('slot_duration', slotDuration.toString());
    
    await updateFacilitySettings(formData);
    
    setLoading(false);
    setIsOpen(false);
  };

  return (
    <>
      <button 
        onClick={() => setIsOpen(true)}
        className={styles.btnEditSettings}
        title="Edit Facility Settings"
      >
        <Settings size={14} /> Edit Settings
      </button>

      {isOpen && (
        <div className={styles.modalOverlay}>
          <div className={styles.modalContent}>
            <div className={styles.modalHeader}>
              <h3>Edit {facility.name}</h3>
              <button onClick={() => setIsOpen(false)} className={styles.closeBtn}>×</button>
            </div>
            
            <form onSubmit={handleSubmit} className={styles.modalForm}>
              <div className={styles.formGroup}>
                <label>Opening Time</label>
                <input 
                  type="time" 
                  value={openTime}
                  onChange={(e) => setOpenTime(e.target.value)}
                  required
                />
              </div>
              
              <div className={styles.formGroup}>
                <label>Closing Time</label>
                <input 
                  type="time" 
                  value={closeTime}
                  onChange={(e) => setCloseTime(e.target.value)}
                  required
                />
              </div>

              <div className={styles.formGroup}>
                <label>Slot Duration (Hours)</label>
                <input 
                  type="number" 
                  min="1"
                  max="24"
                  value={slotDuration}
                  onChange={(e) => setSlotDuration(Number(e.target.value))}
                  required
                />
                <small>How long is one bookable session?</small>
              </div>
              
              <div className={styles.modalFooter}>
                <button type="button" onClick={() => setIsOpen(false)} className={styles.btnCancel}>Cancel</button>
                <button type="submit" disabled={loading} className={styles.btnSave}>
                  {loading ? 'Saving...' : 'Save Settings'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  );
}
