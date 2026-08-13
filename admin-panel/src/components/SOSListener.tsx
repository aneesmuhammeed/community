'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/utils/supabase/client';
import { AlertTriangle, X } from 'lucide-react';
import styles from './SOSListener.module.css';

export default function SOSListener() {
  const [activeAlert, setActiveAlert] = useState<any | null>(null);
  const [residentDetails, setResidentDetails] = useState<any | null>(null);
  const supabase = createClient();

  useEffect(() => {
    // Check if there are any existing active SOS alerts first
    const checkExisting = async () => {
      const { data } = await supabase
        .from('sos_alerts')
        .select('*')
        .eq('status', 'active')
        .order('created_at', { ascending: false })
        .limit(1);
        
      if (data && data.length > 0) {
        handleNewAlert(data[0]);
      }
    };
    
    checkExisting();

    const channel = supabase
      .channel('sos_alerts_changes')
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'sos_alerts',
          filter: 'status=eq.active'
        },
        (payload) => {
          handleNewAlert(payload.new);
        }
      )
      .on(
        'postgres_changes',
        {
          event: 'UPDATE',
          schema: 'public',
          table: 'sos_alerts',
          filter: 'status=eq.resolved'
        },
        (payload) => {
          // If the currently active alert was resolved (by another guard), dismiss it
          if (activeAlert && payload.new.id === activeAlert.id) {
            setActiveAlert(null);
          }
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, [activeAlert, supabase]);

  const handleNewAlert = async (alert: any) => {
    setActiveAlert(alert);
    
    // Fetch resident details for the alert
    const { data } = await supabase
      .from('v_resident_details')
      .select('name, apartment, block, phone')
      .eq('user_id', alert.resident_id)
      .single();
      
    if (data) {
      setResidentDetails(data);
    }
    
    // Play an alarm sound
    try {
      const audio = new Audio('/alarm.mp3'); // We'll assume they have an alarm sound or it fails silently
      audio.play().catch(e => console.log('Audio autoplay blocked', e));
    } catch(e) {}
  };

  const resolveAlert = async () => {
    if (!activeAlert) return;
    
    // Mark as resolved in DB
    await supabase
      .from('sos_alerts')
      .update({ status: 'resolved', resolved_at: new Date().toISOString() })
      .eq('id', activeAlert.id);
      
    setActiveAlert(null);
    setResidentDetails(null);
  };

  if (!activeAlert) return null;

  return (
    <div className={styles.overlay}>
      <div className={styles.alertBox}>
        <div className={styles.iconContainer}>
          <AlertTriangle size={64} className={styles.pulseIcon} color="#ef4444" />
        </div>
        
        <h1 className={styles.title}>EMERGENCY SOS</h1>
        <div className={styles.subtitle}>Resident triggered a panic alert!</div>
        
        {residentDetails ? (
          <div className={styles.detailsBox}>
            <div className={styles.location}>
              <span className={styles.label}>Location:</span>
              <span className={styles.value}>{residentDetails.block} - {residentDetails.apartment}</span>
            </div>
            <div className={styles.person}>
              <span className={styles.label}>Resident:</span>
              <span className={styles.value}>{residentDetails.name}</span>
            </div>
            {residentDetails.phone && (
              <div className={styles.person}>
                <span className={styles.label}>Phone:</span>
                <span className={styles.value}>{residentDetails.phone}</span>
              </div>
            )}
          </div>
        ) : (
          <div className={styles.loadingDetails}>Loading resident information...</div>
        )}
        
        <button onClick={resolveAlert} className={styles.resolveButton}>
          Mark as Resolved
        </button>
      </div>
    </div>
  );
}
