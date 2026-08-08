import { supabase } from '@/lib/supabase';
import { approveVisitor, denyVisitor, checkoutVisitor } from '../dashboard/actions';
import styles from '../dashboard/dashboard.module.css';
import OtpForm from './OtpForm';
import SubmitButton from './SubmitButton';
import { UserCheck, ShieldCheck, DoorOpen, Users, MapPin, Clock, CalendarDays } from 'lucide-react';
import Link from 'next/link';

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
          <h1 className={styles.title}>Visitor Control</h1>
          <p className={styles.subtitle}>Manage and track all guest passes</p>
        </div>
        
        <div style={{ display: 'flex', gap: '8px', padding: '4px', background: '#f8fafc', borderRadius: '12px', border: '1px solid #e2e8f0' }}>
          <Link href="?status=all" className={filterStatus === 'all' ? styles.btnAction : styles.btnSecondary} style={{ padding: '8px 16px', borderRadius: '8px', textDecoration: 'none', fontSize: '14px', fontWeight: '500', transition: 'all 0.2s', display: 'flex', alignItems: 'center', gap: '6px' }}>
            <Users size={16} /> All
          </Link>
          <Link href="?status=active" className={filterStatus === 'active' ? styles.btnAction : styles.btnSecondary} style={{ padding: '8px 16px', borderRadius: '8px', textDecoration: 'none', fontSize: '14px', fontWeight: '500', transition: 'all 0.2s', display: 'flex', alignItems: 'center', gap: '6px' }}>
            <ShieldCheck size={16} /> Pending
          </Link>
          <Link href="?status=approved" className={filterStatus === 'approved' ? styles.btnAction : styles.btnSecondary} style={{ padding: '8px 16px', borderRadius: '8px', textDecoration: 'none', fontSize: '14px', fontWeight: '500', transition: 'all 0.2s', display: 'flex', alignItems: 'center', gap: '6px' }}>
            <UserCheck size={16} /> Approved
          </Link>
          <Link href="?status=entered" className={filterStatus === 'entered' ? styles.btnAction : styles.btnSecondary} style={{ padding: '8px 16px', borderRadius: '8px', textDecoration: 'none', fontSize: '14px', fontWeight: '500', transition: 'all 0.2s', display: 'flex', alignItems: 'center', gap: '6px' }}>
            <DoorOpen size={16} /> Inside
          </Link>
        </div>
      </div>

      <OtpForm />

      <div className={styles.listCard}>
        <div className={styles.listHeader}>
          <h3>Visitor Passes <span style={{ color: '#64748b', fontWeight: 'normal', fontSize: '14px' }}>({visitors.length})</span></h3>
        </div>

        <div className={styles.list}>
          {visitors.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '64px 24px', color: '#94a3b8' }}>
              <div style={{ marginBottom: '16px', display: 'flex', justifyContent: 'center' }}>
                <div style={{ padding: '16px', background: '#f1f5f9', borderRadius: '16px' }}>
                  <Users size={32} color="#94A3B8" />
                </div>
              </div>
              <h3 style={{ fontSize: '16px', fontWeight: 600, color: '#1e293b', marginBottom: '8px' }}>No Visitors Found</h3>
              <p style={{ fontSize: '14px' }}>There are no visitors matching the current filter.</p>
            </div>
          ) : (
            visitors.map((v, i) => {
              const formattedDate = new Date(v.created_at).toLocaleString('en-US', { month: 'short', day: 'numeric', hour: 'numeric', minute: 'numeric' });
              
              return (
              <div key={i} className={styles.listItem} style={{ padding: '20px 0' }}>
                <div className={styles.avatarPlaceholder} style={{ width: '48px', height: '48px', fontSize: '20px', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'linear-gradient(135deg, #f1f5f9 0%, #e2e8f0 100%)', color: '#475569', fontWeight: 'bold' }}>
                  {v.guest_name.charAt(0).toUpperCase()}
                </div>
                <div className={styles.itemContent} style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
                  <div className={styles.itemTitle} style={{ fontSize: '15px' }}>{v.guest_name}</div>
                  <div className={styles.itemMeta} style={{ display: 'flex', gap: '16px', color: '#64748b' }}>
                    <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}><MapPin size={14} /> {v.unit_number} ({v.resident_name})</span>
                    <span style={{ display: 'flex', alignItems: 'center', gap: '4px' }}><UserCheck size={14} /> {v.purpose}</span>
                  </div>
                  <div className={styles.itemTime} style={{ display: 'flex', alignItems: 'center', gap: '4px', marginTop: '2px', color: '#94a3b8' }}>
                    <CalendarDays size={13} /> {formattedDate}
                  </div>
                </div>
                
                <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
                  <div className={`${styles.statusBadge} ${styles[v.status.replace('_', '').toLowerCase()] || styles.inProgress}`} style={{ padding: '6px 12px', fontSize: '12px' }}>
                    {v.status.charAt(0).toUpperCase() + v.status.slice(1)}
                  </div>
                  
                  {v.status === 'active' && (
                    <div className={styles.actions} style={{ display: 'flex', gap: '8px' }}>
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
              )
            })
          )}
        </div>
      </div>
    </div>
  );
}
