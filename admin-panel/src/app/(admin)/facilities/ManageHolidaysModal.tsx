'use client';

import React, { useState, useEffect } from 'react';
import styles from './facilities.module.css';
import { supabase } from '@/lib/supabase';

type Holiday = {
  id: string;
  date: string;
  name: string;
};

export default function ManageHolidaysModal({ societyId }: { societyId: string }) {
  const [isOpen, setIsOpen] = useState(false);
  const [holidays, setHolidays] = useState<Holiday[]>([]);
  const [newDate, setNewDate] = useState('');
  const [newName, setNewName] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (isOpen) {
      fetchHolidays();
    }
  }, [isOpen]);

  const fetchHolidays = async () => {
    const { data, error } = await supabase
      .from('holidays')
      .select('*')
      .eq('society_id', societyId)
      .order('date', { ascending: true });
    
    if (data) setHolidays(data);
  };

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newDate || !newName) return;
    setLoading(true);
    
    await supabase.from('holidays').insert({
      society_id: societyId,
      date: newDate,
      name: newName
    });
    
    setNewDate('');
    setNewName('');
    await fetchHolidays();
    setLoading(false);
  };

  const handleDelete = async (id: string) => {
    setLoading(true);
    await supabase.from('holidays').delete().eq('id', id);
    await fetchHolidays();
    setLoading(false);
  };

  return (
    <>
      <button className={styles.secondaryBtn} onClick={() => setIsOpen(true)}>
        🗓️ Manage Holidays
      </button>

      {isOpen && (
        <div className={styles.modalOverlay} onClick={() => setIsOpen(false)}>
          <div className={styles.modalContent} onClick={(e) => e.stopPropagation()}>
            <div className={styles.modalHeader}>
              <h2>Manage Holidays</h2>
              <button className={styles.closeBtn} onClick={() => setIsOpen(false)}>&times;</button>
            </div>
            
            <form onSubmit={handleAdd} className={styles.holidayForm}>
              <div style={{ display: 'flex', gap: '12px', marginBottom: '20px' }}>
                <input 
                  type="date" 
                  value={newDate} 
                  onChange={(e) => setNewDate(e.target.value)}
                  className={styles.inputField}
                  required
                />
                <input 
                  type="text" 
                  placeholder="Holiday Name (e.g., Christmas)" 
                  value={newName} 
                  onChange={(e) => setNewName(e.target.value)}
                  className={styles.inputField}
                  required
                />
                <button type="submit" className={styles.primaryBtn} disabled={loading}>
                  Add
                </button>
              </div>
            </form>

            <div className={styles.holidayList}>
              {holidays.length === 0 ? (
                <p>No holidays defined yet.</p>
              ) : (
                <table style={{ width: '100%', textAlign: 'left', borderCollapse: 'collapse' }}>
                  <thead>
                    <tr>
                      <th style={{ borderBottom: '1px solid #e2e8f0', padding: '8px' }}>Date</th>
                      <th style={{ borderBottom: '1px solid #e2e8f0', padding: '8px' }}>Name</th>
                      <th style={{ borderBottom: '1px solid #e2e8f0', padding: '8px' }}>Actions</th>
                    </tr>
                  </thead>
                  <tbody>
                    {holidays.map(h => (
                      <tr key={h.id}>
                        <td style={{ padding: '8px', borderBottom: '1px solid #f1f5f9' }}>{new Date(h.date).toLocaleDateString()}</td>
                        <td style={{ padding: '8px', borderBottom: '1px solid #f1f5f9' }}>{h.name}</td>
                        <td style={{ padding: '8px', borderBottom: '1px solid #f1f5f9' }}>
                          <button onClick={() => handleDelete(h.id)} disabled={loading} style={{ color: 'red', background: 'none', border: 'none', cursor: 'pointer' }}>Delete</button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              )}
            </div>
          </div>
        </div>
      )}
    </>
  );
}
