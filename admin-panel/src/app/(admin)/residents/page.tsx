import styles from './residents.module.css';
import { supabase } from '@/lib/supabase';
import ResidentItem from './ResidentItem';

export const revalidate = 0;

export default async function ResidentsPage() {
  const SOCIETY_ID = process.env.NEXT_PUBLIC_SOCIETY_ID || '11111111-1111-1111-1111-111111111111';

  // Fetch residents and apartments concurrently
  const [
    { data: residents },
    { data: apartments }
  ] = await Promise.all([
    supabase.from('v_resident_details').select('*').eq('society_id', SOCIETY_ID).order('unit_number'),
    supabase.from('apartments').select('id, unit_number, blocks(name)').eq('society_id', SOCIETY_ID).order('unit_number')
  ]);

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
            <ResidentItem key={resident.resident_id} resident={resident} apartments={apartments || []} />
          ))
        )}
      </div>
    </div>
  );
}
