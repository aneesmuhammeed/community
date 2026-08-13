import { supabase } from '@/lib/supabase';
import { approveVisitor, denyVisitor, checkoutVisitor } from '../dashboard/actions';
import styles from '../dashboard/dashboard.module.css';
import vStyles from './visitors.module.css';
import OtpForm from './OtpForm';
import SubmitButton from './SubmitButton';
import CopyOtpButton from './CopyOtpButton';
import { UserCheck, ShieldCheck, DoorOpen, Users, MapPin, CalendarDays, KeyRound } from 'lucide-react';
import Link from 'next/link';

export const revalidate = 0;

export default async function VisitorsPage({
  searchParams,
}: {
  searchParams: Promise<{ status?: string }>
}) {
  const SOCIETY_ID = process.env.NEXT_PUBLIC_SOCIETY_ID || '11111111-1111-1111-1111-111111111111';
  const params = await searchParams;
  const filterStatus = params.status || 'all';

  let query = supabase
    .from('visitors')
    .select('*')
    .eq('society_id', SOCIETY_ID)
    .order('created_at', { ascending: false })
    .limit(100);

  if (filterStatus !== 'all') {
    if (filterStatus === 'entered') {
      query = query.not('arrived_at', 'is', null).is('left_at', null);
    } else {
      query = query.eq('status', filterStatus);
    }
  }

  const [
    { data: rawVisitors },
    { data: details }
  ] = await Promise.all([
    query,
    supabase.from('v_resident_details').select('resident_id, full_name, unit_number').eq('society_id', SOCIETY_ID)
  ]);
  
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
        
        <div className={vStyles.filterBar}>
          <Link href="?status=all" className={`${vStyles.filterTab} ${filterStatus === 'all' ? vStyles.filterTabActive : ''}`}>
            <Users size={15} /> All
          </Link>
          <Link href="?status=active" className={`${vStyles.filterTab} ${filterStatus === 'active' ? vStyles.filterTabActive : ''}`}>
            <ShieldCheck size={15} /> Pending
          </Link>
          <Link href="?status=approved" className={`${vStyles.filterTab} ${filterStatus === 'approved' ? vStyles.filterTabActive : ''}`}>
            <UserCheck size={15} /> Approved
          </Link>
          <Link href="?status=entered" className={`${vStyles.filterTab} ${filterStatus === 'entered' ? vStyles.filterTabActive : ''}`}>
            <DoorOpen size={15} /> Inside
          </Link>
        </div>
      </div>

      <OtpForm />

      <div className={styles.listCard}>
        <div className={styles.listHeader}>
          <h3>Visitor Passes <span style={{ color: 'var(--muted)', fontWeight: 'normal', fontSize: '0.8125rem' }}>({visitors.length})</span></h3>
        </div>

        <div className={styles.list}>
          {visitors.length === 0 ? (
            <div className={vStyles.emptyState}>
              <div className={vStyles.emptyIcon}>
                <div className={vStyles.emptyIconWrapper}>
                  <Users size={28} color="#94A3B8" />
                </div>
              </div>
              <h3 className={vStyles.emptyTitle}>No Visitors Found</h3>
              <p className={vStyles.emptyText}>There are no visitors matching the current filter.</p>
            </div>
          ) : (
            visitors.map((v, i) => {
              const formattedDate = new Date(v.created_at).toLocaleString('en-US', { month: 'short', day: 'numeric', hour: 'numeric', minute: 'numeric' });
              
              return (
              <div key={i} className={vStyles.visitorItem}>
                <div className={vStyles.visitorAvatar}>
                  {v.guest_name.charAt(0).toUpperCase()}
                </div>
                <div className={vStyles.visitorInfo}>
                  <div className={vStyles.visitorName}>{v.guest_name}</div>
                  <div className={vStyles.visitorMeta}>
                    <span className={vStyles.visitorMetaItem}><MapPin size={13} /> Flat: {v.unit_number} ({v.resident_name})</span>
                    <span className={vStyles.visitorMetaItem}><UserCheck size={13} /> {v.purpose}</span>
                  </div>
                  <div className={vStyles.visitorTime}>
                    <CalendarDays size={12} /> {formattedDate}
                  </div>
                  {v.otp_value && (
                    <div className={vStyles.visitorMetaItem}>
                      <KeyRound size={12} color="#94a3b8" />
                      <CopyOtpButton otp={v.otp_value} guestName={v.guest_name} flat={v.unit_number} />
                    </div>
                  )}
                </div>
                
                <div className={vStyles.visitorActions}>
                  <div className={`${styles.statusBadge} ${styles[v.status.replace('_', '').toLowerCase()] || styles.inprogress}`}>
                    {v.status.charAt(0).toUpperCase() + v.status.slice(1)}
                  </div>
                  
                  {v.status === 'active' && (
                    <div className={vStyles.visitorActionButtons}>
                      <form action={approveVisitor as any} style={{ display: 'inline' }}>
                        <input type="hidden" name="id" value={v.id} />
                        <SubmitButton label="Approve" loadingLabel="Wait..." variant="primary" />
                      </form>
                      <form action={denyVisitor as any} style={{ display: 'inline' }}>
                        <input type="hidden" name="id" value={v.id} />
                        <SubmitButton label="Deny" loadingLabel="Wait..." variant="danger" />
                      </form>
                    </div>
                  )}
                  
                  {v.arrived_at !== null && v.left_at === null && (
                    <div className={vStyles.visitorActionButtons}>
                      <form action={checkoutVisitor as any} style={{ display: 'inline' }}>
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
