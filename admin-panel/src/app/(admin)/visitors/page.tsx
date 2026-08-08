import { supabase } from '@/lib/supabase';
import { approveVisitor, denyVisitor, checkoutVisitor } from '../dashboard/actions';
import styles from '../dashboard/dashboard.module.css';
import OtpForm from './OtpForm';
import SubmitButton from './SubmitButton';

export const revalidate = 0;

export default async function VisitorsPage({
  searchParams,
}: {
  searchParams: Promise<{ status?: string }>
}) {
  const SOCIETY_ID = '11111111-1111-1111-1111-111111111111';
  const params = await searchParams;
  const filterStatus = params.status || 'all';

  let query = supabase
    .from('visitors')
    .select('*')
    .eq('society_id', SOCIETY_ID)
    .order('created_at', { ascending: false });

  if (filterStatus !== 'all') {
    if (filterStatus === 'entered') {
      query = query.not('arrived_at', 'is', null).is('left_at', null);
    } else {
      query = query.eq('status', filterStatus);
    }
  }

  const { data: rawVisitors } = await query;
  
  // Bypass RLS on apartments/profiles by using v_resident_details
  const { data: details } = await supabase.from('v_resident_details').select('resident_id, full_name, unit_number').eq('society_id', SOCIETY_ID);
  
  const detailsMap: Record<string, any> = {};
  if (details) {
    details.forEach(d => {
      detailsMap[d.resident_id] = d;
    });
  }
  
  const visitors = rawVisitors?.map(v => ({
    ...v,
    resident_name: detailsMap[v.resident_id]?.full_name || 'Unknown',
    unit_number: detailsMap[v.resident_id]?.unit_number || 'Unknown',
  })) || [];

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <div>
          <h1>Visitor Control</h1>
          <p>Manage and track all guest passes</p>
        </div>
        
        <div style={{ display: 'flex', gap: '8px' }}>
          <a href="?status=all" className={filterStatus === 'all' ? styles.btnAction : styles.btnSecondary} style={filterStatus !== 'all' ? { background: '#f1f5f9', color: '#475569', border: 'none', padding: '8px 16px', borderRadius: '8px', textDecoration: 'none', fontSize: '14px', fontWeight: '500' } : { textDecoration: 'none' }}>All</a>
          <a href="?status=active" className={filterStatus === 'active' ? styles.btnAction : styles.btnSecondary} style={filterStatus !== 'active' ? { background: '#f1f5f9', color: '#475569', border: 'none', padding: '8px 16px', borderRadius: '8px', textDecoration: 'none', fontSize: '14px', fontWeight: '500' } : { textDecoration: 'none' }}>Pending</a>
          <a href="?status=approved" className={filterStatus === 'approved' ? styles.btnAction : styles.btnSecondary} style={filterStatus !== 'approved' ? { background: '#f1f5f9', color: '#475569', border: 'none', padding: '8px 16px', borderRadius: '8px', textDecoration: 'none', fontSize: '14px', fontWeight: '500' } : { textDecoration: 'none' }}>Approved</a>
          <a href="?status=entered" className={filterStatus === 'entered' ? styles.btnAction : styles.btnSecondary} style={filterStatus !== 'entered' ? { background: '#f1f5f9', color: '#475569', border: 'none', padding: '8px 16px', borderRadius: '8px', textDecoration: 'none', fontSize: '14px', fontWeight: '500' } : { textDecoration: 'none' }}>Inside</a>
        </div>
      </div>

      <OtpForm />

      <div className={styles.listCard}>
        <div className={styles.listHeader}>
          <h3>Visitor Passes ({visitors.length})</h3>
        </div>

        <div className={styles.list}>
          {visitors.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '48px 24px', color: '#94a3b8' }}>
              <div style={{ marginBottom: '16px' }}>
                <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                  <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                  <line x1="16" y1="2" x2="16" y2="6"></line>
                  <line x1="8" y1="2" x2="8" y2="6"></line>
                  <line x1="3" y1="10" x2="21" y2="10"></line>
                </svg>
              </div>
              <h3 style={{ fontSize: '16px', fontWeight: 600, color: '#1e293b', marginBottom: '8px' }}>No Visitors Found</h3>
              <p style={{ fontSize: '14px' }}>There are no visitors matching the current filter.</p>
            </div>
          ) : (
            visitors.map((v, i) => (
              <div key={i} className={styles.listItem}>
                <div className={styles.avatarPlaceholder}></div>
                <div className={styles.itemContent}>
                  <div className={styles.itemTitle}>{v.guest_name}</div>
                  <div className={styles.itemMeta}>{v.resident_name} - {v.unit_number} - {v.purpose}</div>
                  <div className={styles.itemTime}>{new Date(v.created_at).toLocaleString()}</div>
                </div>
                
                <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                  <div className={`${styles.statusBadge} ${styles[v.status.replace('_', '').toLowerCase()] || styles.inProgress}`}>
                    {v.status}
                  </div>
                  
                  {v.status === 'active' && (
                    <div className={styles.actions}>
                      <form action={approveVisitor} style={{ display: 'inline' }}>
                        <input type="hidden" name="id" value={v.id} />
                        <SubmitButton label="Approve" loadingLabel="Wait..." variant="primary" />
                      </form>
                      <form action={denyVisitor} style={{ display: 'inline' }}>
                        <input type="hidden" name="id" value={v.id} />
                        <SubmitButton label="Deny" loadingLabel="Wait..." variant="danger" />
                      </form>
                    </div>
                  )}
                  
                  {v.arrived_at !== null && v.left_at === null && (
                    <div className={styles.actions}>
                      <form action={checkoutVisitor} style={{ display: 'inline' }}>
                        <input type="hidden" name="id" value={v.id} />
                        <SubmitButton label="Checkout" loadingLabel="Wait..." variant="secondary" />
                      </form>
                    </div>
                  )}
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}
