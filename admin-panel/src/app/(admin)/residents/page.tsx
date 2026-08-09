import styles from './residents.module.css';
import { supabase } from '@/lib/supabase';
import { MapPin, User, Shield } from 'lucide-react';
import { toggleResidentStatus } from './actions';

export const revalidate = 0;

export default async function ResidentsPage() {
  const SOCIETY_ID = process.env.NEXT_PUBLIC_SOCIETY_ID || '11111111-1111-1111-1111-111111111111';

  // Fetch residents from v_resident_details
  const { data: residents } = await supabase
    .from('v_resident_details')
    .select('*')
    .eq('society_id', SOCIETY_ID)
    .order('unit_number');

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <h1 className={styles.title}>Residents Management</h1>
        <p className={styles.subtitle}>Manage resident access, roles, and details.</p>
      </div>

      <h2 className={styles.sectionTitle}>All Residents</h2>
      <div className={styles.residentsList}>
        {!residents || residents.length === 0 ? (
          <div className={styles.emptyState}>No residents found in this society.</div>
        ) : (
          residents.map((resident) => (
            <div key={resident.resident_id} className={styles.residentItem}>
              <div className={styles.residentInfo}>
                <div className={styles.residentAvatar}>
                  {resident.full_name?.charAt(0)?.toUpperCase() || 'U'}
                </div>
                <div className={styles.residentDetails}>
                  <div className={styles.residentName}>{resident.full_name || 'Unknown Resident'}</div>
                  <div className={styles.residentMeta}>
                    <div className={styles.residentMetaItem}>
                      <MapPin size={12} /> {resident.block_name ? `${resident.block_name} - ` : ''}Flat {resident.unit_number || 'N/A'}
                    </div>
                    <div className={styles.residentMetaItem}>
                      <User size={12} /> {resident.ownership || 'Unknown'}
                    </div>
                    <div className={styles.residentMetaItem}>
                      <Shield size={12} /> {resident.role || 'resident'}
                    </div>
                  </div>
                </div>
              </div>
              
              <div className={styles.residentActions}>
                <div className={`${styles.statusBadge} ${resident.is_active ? styles.statusactive : styles.statusinactive}`}>
                  {resident.is_active ? 'Active' : 'Inactive'}
                </div>
                
                <div className={styles.actionButtons}>
                  <form action={toggleResidentStatus.bind(null, resident.resident_id, resident.is_active)}>
                    <button type="submit" className={styles.btnToggle}>
                      {resident.is_active ? 'Deactivate' : 'Activate'}
                    </button>
                  </form>
                </div>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
