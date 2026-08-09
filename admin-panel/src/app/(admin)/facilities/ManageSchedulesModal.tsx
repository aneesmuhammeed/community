'use client';

import React, { useState, useEffect } from 'react';
import styles from './facilities.module.css';
import { supabase } from '@/lib/supabase';

type Schedule = {
  id: string;
  day_type: 'WEEKDAY' | 'WEEKEND' | 'HOLIDAY';
  start_time: string;
  end_time: string;
};

type SlotBlock = {
  id: string;
  date: string;
  start_time: string;
  end_time: string;
  reason: string;
};

export default function ManageSchedulesModal({ facility }: { facility: any }) {
  const [isOpen, setIsOpen] = useState(false);
  const [schedules, setSchedules] = useState<Schedule[]>([]);
  const [blocks, setBlocks] = useState<SlotBlock[]>([]);
  const [loading, setLoading] = useState(false);
  const [activeTab, setActiveTab] = useState<'schedules' | 'blocks'>('schedules');

  // Schedule form
  const [dayType, setDayType] = useState<'WEEKDAY' | 'WEEKEND' | 'HOLIDAY'>('WEEKDAY');
  const [startTime, setStartTime] = useState('09:00');
  const [endTime, setEndTime] = useState('10:00');

  // Block form
  const [blockDate, setBlockDate] = useState('');
  const [blockStart, setBlockStart] = useState('09:00');
  const [blockEnd, setBlockEnd] = useState('10:00');
  const [blockReason, setBlockReason] = useState('Maintenance');

  useEffect(() => {
    if (isOpen) {
      fetchData();
    }
  }, [isOpen]);

  const fetchData = async () => {
    setLoading(true);
    const { data: schedData } = await supabase
      .from('facility_schedules')
      .select('*')
      .eq('facility_id', facility.id)
      .order('day_type')
      .order('start_time');
    
    if (schedData) setSchedules(schedData);

    const { data: blockData } = await supabase
      .from('facility_slot_blocks')
      .select('*')
      .eq('facility_id', facility.id)
      .order('date', { ascending: false });

    if (blockData) setBlocks(blockData);
    setLoading(false);
  };

  const handleAddSchedule = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    await supabase.from('facility_schedules').insert({
      facility_id: facility.id,
      day_type: dayType,
      start_time: startTime,
      end_time: endTime
    });
    await fetchData();
  };

  const handleDeleteSchedule = async (id: string) => {
    setLoading(true);
    await supabase.from('facility_schedules').delete().eq('id', id);
    await fetchData();
  };

  const handleAddBlock = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!blockDate) return;
    setLoading(true);
    await supabase.from('facility_slot_blocks').insert({
      facility_id: facility.id,
      date: blockDate,
      start_time: blockStart,
      end_time: blockEnd,
      reason: blockReason
    });
    setBlockDate('');
    await fetchData();
  };

  const handleDeleteBlock = async (id: string) => {
    setLoading(true);
    await supabase.from('facility_slot_blocks').delete().eq('id', id);
    await fetchData();
  };

  return (
    <>
      <button className={styles.secondaryBtn} onClick={() => setIsOpen(true)} style={{ marginTop: '10px', width: '100%' }}>
        📅 Manage Schedule & Blocks
      </button>

      {isOpen && (
        <div className={styles.modalOverlay} onClick={() => setIsOpen(false)}>
          <div className={styles.modalContent} style={{ maxWidth: '600px' }} onClick={(e) => e.stopPropagation()}>
            <div className={styles.modalHeader}>
              <h2>Schedule for {facility.name}</h2>
              <button className={styles.closeBtn} onClick={() => setIsOpen(false)}>&times;</button>
            </div>
            
            <div style={{ display: 'flex', gap: '10px', marginBottom: '20px' }}>
              <button 
                onClick={() => setActiveTab('schedules')} 
                style={{ padding: '8px 16px', background: activeTab === 'schedules' ? '#2563EB' : '#e2e8f0', color: activeTab === 'schedules' ? '#fff' : '#000', border: 'none', borderRadius: '8px' }}
              >
                Recurring Rules
              </button>
              <button 
                onClick={() => setActiveTab('blocks')} 
                style={{ padding: '8px 16px', background: activeTab === 'blocks' ? '#2563EB' : '#e2e8f0', color: activeTab === 'blocks' ? '#fff' : '#000', border: 'none', borderRadius: '8px' }}
              >
                Slot Overrides / Blocks
              </button>
            </div>

            {activeTab === 'schedules' && (
              <div>
                <form onSubmit={handleAddSchedule} style={{ display: 'flex', gap: '10px', marginBottom: '20px' }}>
                  <select value={dayType} onChange={(e: any) => setDayType(e.target.value)} className={styles.inputField}>
                    <option value="WEEKDAY">Weekday</option>
                    <option value="WEEKEND">Weekend</option>
                    <option value="HOLIDAY">Holiday</option>
                  </select>
                  <input type="time" value={startTime} onChange={(e) => setStartTime(e.target.value)} className={styles.inputField} required />
                  <span style={{ alignSelf: 'center' }}>to</span>
                  <input type="time" value={endTime} onChange={(e) => setEndTime(e.target.value)} className={styles.inputField} required />
                  <button type="submit" className={styles.primaryBtn} disabled={loading}>Add</button>
                </form>

                {schedules.map(s => (
                  <div key={s.id} style={{ display: 'flex', justifyContent: 'space-between', padding: '10px', borderBottom: '1px solid #eee' }}>
                    <span><strong>{s.day_type}</strong>: {s.start_time.substring(0,5)} - {s.end_time.substring(0,5)}</span>
                    <button onClick={() => handleDeleteSchedule(s.id)} disabled={loading} style={{ color: 'red', background: 'none', border: 'none', cursor: 'pointer' }}>Delete</button>
                  </div>
                ))}
              </div>
            )}

            {activeTab === 'blocks' && (
              <div>
                <p style={{ marginBottom: '10px', fontSize: '14px', color: '#64748b' }}>Block a specific slot on a specific date to prevent bookings.</p>
                <form onSubmit={handleAddBlock} style={{ display: 'flex', flexWrap: 'wrap', gap: '10px', marginBottom: '20px' }}>
                  <input type="date" value={blockDate} onChange={(e) => setBlockDate(e.target.value)} className={styles.inputField} required />
                  <input type="time" value={blockStart} onChange={(e) => setBlockStart(e.target.value)} className={styles.inputField} required />
                  <span style={{ alignSelf: 'center' }}>to</span>
                  <input type="time" value={blockEnd} onChange={(e) => setBlockEnd(e.target.value)} className={styles.inputField} required />
                  <input type="text" placeholder="Reason (e.g. Cleaning)" value={blockReason} onChange={(e) => setBlockReason(e.target.value)} className={styles.inputField} style={{ flexGrow: 1 }} required />
                  <button type="submit" className={styles.primaryBtn} disabled={loading}>Block Slot</button>
                </form>

                {blocks.map(b => (
                  <div key={b.id} style={{ display: 'flex', justifyContent: 'space-between', padding: '10px', borderBottom: '1px solid #eee' }}>
                    <div>
                      <strong>{new Date(b.date).toLocaleDateString()}</strong> {b.start_time.substring(0,5)} - {b.end_time.substring(0,5)}
                      <br /><span style={{ fontSize: '12px', color: '#64748b' }}>{b.reason}</span>
                    </div>
                    <button onClick={() => handleDeleteBlock(b.id)} disabled={loading} style={{ color: 'red', background: 'none', border: 'none', cursor: 'pointer' }}>Delete</button>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}
    </>
  );
}
