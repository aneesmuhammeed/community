'use client';

import { useState } from 'react';
import styles from './facilities.module.css';
import { addFacility } from './actions';
import { Plus } from 'lucide-react';

export default function CreateFacilityModal({ societyId }: { societyId: string }) {
  const [isOpen, setIsOpen] = useState(false);
  const [loading, setLoading] = useState(false);

  const [name, setName] = useState('');
  const [capacity, setCapacity] = useState(20);
  const [openTime, setOpenTime] = useState('06:00');
  const [closeTime, setCloseTime] = useState('22:00');
  const [slotDuration, setSlotDuration] = useState(1);
  const [bookingFee, setBookingFee] = useState(0);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    
    const formData = new FormData();
    formData.append('society_id', societyId);
    formData.append('name', name);
    formData.append('capacity', capacity.toString());
    formData.append('operating_hours', `${openTime}-${closeTime}`);
    formData.append('slot_duration', slotDuration.toString());
    formData.append('booking_fee', bookingFee.toString());
    
    await addFacility(formData);
    
    setLoading(false);
    setIsOpen(false);
    
    // Reset form
    setName('');
    setCapacity(20);
    setOpenTime('06:00');
    setCloseTime('22:00');
    setSlotDuration(1);
    setBookingFee(0);
  };

  return (
    <>
      <button 
        onClick={() => setIsOpen(true)}
        className={styles.btnAddFacility}
      >
        <Plus size={16} /> Add New Facility
      </button>

      {isOpen && (
        <div className={styles.modalOverlay}>
          <div className={styles.modalContent} style={{ maxWidth: '500px' }}>
            <div className={styles.modalHeader}>
              <h3>Add New Facility</h3>
              <button onClick={() => setIsOpen(false)} className={styles.closeBtn}>×</button>
            </div>
            
            <form onSubmit={handleSubmit} className={styles.modalForm}>
              <div className={styles.formGroup}>
                <label>Facility Name</label>
                <select 
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  required
                >
                  <option value="" disabled>Select a facility...</option>
                  <option value="Clubhouse">Clubhouse</option>
                  <option value="Gym">Gym</option>
                  <option value="Party Hall">Party Hall</option>
                  <option value="Tennis Court">Tennis Court</option>
                  <option value="Pool">Pool</option>
                </select>
              </div>

              <div style={{ display: 'flex', gap: '16px' }}>
                <div className={styles.formGroup} style={{ flex: 1 }}>
                  <label>Capacity</label>
                  <input 
                    type="number" 
                    value={capacity}
                    onChange={(e) => setCapacity(Number(e.target.value))}
                    min="1"
                    required
                  />
                </div>
                
                <div className={styles.formGroup} style={{ flex: 1 }}>
                  <label>Booking Fee (₹)</label>
                  <input 
                    type="number" 
                    value={bookingFee}
                    onChange={(e) => setBookingFee(Number(e.target.value))}
                    min="0"
                    required
                  />
                </div>
              </div>
              
              <div style={{ display: 'flex', gap: '16px' }}>
                <div className={styles.formGroup} style={{ flex: 1 }}>
                  <label>Opening Time</label>
                  <input 
                    type="time" 
                    value={openTime}
                    onChange={(e) => setOpenTime(e.target.value)}
                    required
                  />
                </div>
                
                <div className={styles.formGroup} style={{ flex: 1 }}>
                  <label>Closing Time</label>
                  <input 
                    type="time" 
                    value={closeTime}
                    onChange={(e) => setCloseTime(e.target.value)}
                    required
                  />
                </div>
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
                  {loading ? 'Creating...' : 'Create Facility'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  );
}
