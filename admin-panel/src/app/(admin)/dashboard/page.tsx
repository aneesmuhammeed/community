import styles from './dashboard.module.css';
import Link from 'next/link';
import { Users, AlertCircle, UserCheck, CreditCard, Calendar } from 'lucide-react';
// import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

import { supabase } from '@/lib/supabase';
import { approveVisitor, denyVisitor } from './actions';
import DashboardCharts from './DashboardCharts';
import { getSocietyId } from '@/utils/supabase/auth';

// Revalidate page data every minute or make it dynamic
export const revalidate = 0;

export default async function DashboardPage() {
  const SOCIETY_ID = await getSocietyId();
  // Fetch stats
  const [
    { count: residentsCount },
    { count: complaintsCount },
    { count: visitorsCount },
    { data: billingData },
    { data: recentComplaints },
    { data: todayVisitorsRaw },
    { data: bookingsData },
    { data: residentDetails }
  ] = await Promise.all([
    supabase.from('residents').select('*', { count: 'exact', head: true }).eq('society_id', SOCIETY_ID),
    supabase.from('complaints').select('*', { count: 'exact', head: true }).eq('society_id', SOCIETY_ID).neq('status', 'resolved'),
    supabase.from('visitors').select('*', { count: 'exact', head: true }).eq('society_id', SOCIETY_ID).eq('status', 'active'), // simplified for today
    supabase.from('billing_cycles').select('billing_month, total_amount, status').eq('society_id', SOCIETY_ID),
    supabase.from('complaints').select('*, apartments(unit_number)').eq('society_id', SOCIETY_ID).order('created_at', { ascending: false }).limit(5),
    supabase.from('visitors').select('*').eq('society_id', SOCIETY_ID).eq('status', 'active').order('created_at', { ascending: false }).limit(5),
    supabase.from('bookings').select('facilities(name)').eq('society_id', SOCIETY_ID),
    supabase.from('v_resident_details').select('resident_id, full_name, unit_number').eq('society_id', SOCIETY_ID)
  ]);

  const pendingDues = billingData?.filter(b => b.status === 'pending') || [];
  const totalDues = pendingDues.reduce((sum, item) => sum + (Number(item.total_amount) || 0), 0);

  // Aggregate Collection Data
  const collectionMap: Record<string, { paid: number, overdue: number }> = {};
  billingData?.forEach(b => {
    const month = b.billing_month;
    if (!collectionMap[month]) collectionMap[month] = { paid: 0, overdue: 0 };
    if (b.status === 'paid') collectionMap[month].paid += Number(b.total_amount) || 0;
    else collectionMap[month].overdue += Number(b.total_amount) || 0;
  });
  const collectionChartData = Object.entries(collectionMap).map(([month, data]) => ({ month, ...data }));

  // Aggregate Facility Data
  const facilityMap: Record<string, number> = {};
  bookingsData?.forEach(b => {
    const fac = b.facilities as any;
    const name = (Array.isArray(fac) ? fac[0]?.name : fac?.name) || 'Unknown';
    facilityMap[name] = (facilityMap[name] || 0) + 1;
  });
  const facilityChartData = Object.entries(facilityMap).map(([name, value]) => ({ name, value }));

  const detailsMap: Record<string, any> = {};
  if (residentDetails) {
    residentDetails.forEach(d => {
      detailsMap[d.resident_id] = d;
    });
  }

  const todayVisitors = todayVisitorsRaw?.map(v => ({
    ...v,
    resident_name: detailsMap[v.resident_id]?.full_name || 'Unknown',
    unit_number: detailsMap[v.resident_id]?.unit_number || 'Unknown'
  })) || [];

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <div>
          <h1 className={styles.title}>Dashboard Overview</h1>
          <p className={styles.subtitle}>Welcome back, Super Admin — here&apos;s what&apos;s happening today.</p>
        </div>
        <div className={styles.datePicker}>
          <Calendar size={16} />
          <span>Nov 28, 2024 · 9:41 AM</span>
        </div>
      </div>

      <div className={styles.statsGrid}>
        <div className={styles.statCard}>
          <div className={styles.statHeader}>
            <div className={`${styles.statIcon} ${styles.bgGreen}`}><Users size={20} className={styles.textGreen} /></div>
            <span className={`${styles.statBadge} ${styles.badgeGreen}`}>↑ 4 this month</span>
          </div>
          <div className={styles.statValue}>{residentsCount || 0}</div>
          <div className={styles.statLabel}>Total Residents</div>
        </div>

        <div className={styles.statCard}>
          <div className={styles.statHeader}>
            <div className={`${styles.statIcon} ${styles.bgRed}`}><AlertCircle size={20} className={styles.textRed} /></div>
            <span className={`${styles.statBadge} ${styles.badgeRed}`}>⚠ {complaintsCount || 0} urgent</span>
          </div>
          <div className={styles.statValue}>{complaintsCount || 0}</div>
          <div className={styles.statLabel}>Active Complaints</div>
        </div>

        <div className={styles.statCard}>
          <div className={styles.statHeader}>
            <div className={`${styles.statIcon} ${styles.bgBlue}`}><UserCheck size={20} className={styles.textBlue} /></div>
            <span className={`${styles.statBadge} ${styles.badgeBlue}`}>⌛ {visitorsCount || 0} pending</span>
          </div>
          <div className={styles.statValue}>{visitorsCount || 0}</div>
          <div className={styles.statLabel}>Today&apos;s Visitors</div>
        </div>

        <div className={styles.statCard}>
          <div className={styles.statHeader}>
            <div className={`${styles.statIcon} ${styles.bgOrange}`}><CreditCard size={20} className={styles.textOrange} /></div>
            <span className={`${styles.statBadge} ${styles.badgeOrange}`}>↘ Unpaid</span>
          </div>
          <div className={styles.statValue}>₹{totalDues.toLocaleString('en-IN')}</div>
          <div className={styles.statLabel}>Pending Dues</div>
        </div>
      </div>

      <DashboardCharts collectionData={collectionChartData} facilityData={facilityChartData} />

      <div className={styles.listsGrid}>
        <div className={styles.listCard}>
          <div className={styles.listHeader}>
            <h3>Recent Complaints</h3>
            <Link href="/complaints" className={styles.viewAll}>View all</Link>
          </div>
          <div className={styles.list}>
            {recentComplaints?.map((c, i) => (
              <div key={i} className={styles.listItem}>
                <div className={styles.itemContent}>
                  <div className={styles.itemMeta}>{c.id?.substring(0, 8)} · Flat: {c.apartments?.unit_number}</div>
                  <div className={styles.itemTitle}>{c.title}</div>
                  <div className={styles.itemTime}>{new Date(c.created_at).toLocaleDateString()}</div>
                </div>
                <div className={`${styles.statusBadge} ${styles[c.status.replace('_', '').toLowerCase()] || styles.inProgress}`}>{c.status}</div>
              </div>
            ))}
          </div>
        </div>

        <div className={styles.listCard}>
          <div className={styles.listHeader}>
            <h3>Today&apos;s Visitor Approvals</h3>
            <div>
              <span className={styles.pendingBadge}>{visitorsCount || 0} pending</span>
              <Link href="/visitors" className={styles.viewAll} style={{ marginLeft: '12px' }}>View all</Link>
            </div>
          </div>
          <div className={styles.list}>
            {todayVisitors?.map((v, i) => (
              <div key={i} className={styles.listItem}>
                <div className={styles.avatarPlaceholder}></div>
                <div className={styles.itemContent}>
                  <div className={styles.itemTitle}>{v.guest_name}</div>
                  <div className={styles.itemMeta}>{v.resident_name} · Flat: {v.unit_number} · {v.purpose}</div>
                  <div className={styles.itemTime}>{new Date(v.created_at).toLocaleTimeString()}</div>
                </div>
                {v.status === 'active' && (
                  <div className={styles.actions}>
                    <form action={approveVisitor as any} style={{ display: 'inline' }}>
                      <input type="hidden" name="id" value={v.id} />
                      <button type="submit" className={styles.btnApprove}>✓ Approve</button>
                    </form>
                    <form action={denyVisitor as any} style={{ display: 'inline' }}>
                      <input type="hidden" name="id" value={v.id} />
                      <button type="submit" className={styles.btnDeny}>✕ Deny</button>
                    </form>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
