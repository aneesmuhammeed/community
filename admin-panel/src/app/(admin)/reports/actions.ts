'use server'

import { supabase } from '@/lib/supabase';

import { requireRole } from '@/utils/supabase/auth';
import { getSocietyId } from '@/utils/supabase/auth';



export async function getReportsData() {
  const SOCIETY_ID = await getSocietyId();
  try { await requireRole(['SUPER_ADMIN', 'COMMUNITY_HEAD', 'ACCOUNTANT']); } catch (e: any) { return null; }
  if (!SOCIETY_ID) return null;

  try {
    const startOfMonth = new Date();
    startOfMonth.setDate(1);
    startOfMonth.setHours(0, 0, 0, 0);
    const startOfMonthISO = startOfMonth.toISOString();

    // 1. Complaints Breakdown
    const { data: complaintsData, error: complaintsError } = await supabase
      .from('complaints')
      .select('status')
      .eq('society_id', SOCIETY_ID)
      .gte('created_at', startOfMonthISO);
      
    if (complaintsError) throw complaintsError;
    
    let openComplaints = 0;
    let resolvedComplaints = 0;
    
    complaintsData?.forEach(c => {
      if (c.status === 'resolved' || c.status === 'closed') resolvedComplaints++;
      else openComplaints++;
    });

    // 2. Visitors Info
    const { data: visitorsData, error: visitorsError } = await supabase
      .from('visitors')
      .select('status')
      .eq('society_id', SOCIETY_ID)
      .gte('created_at', startOfMonthISO);
      
    if (visitorsError) throw visitorsError;
    
    let activeVisitors = 0;
    let completedVisitors = 0;
    
    visitorsData?.forEach(v => {
      if (v.status === 'active' || v.status === 'approved') activeVisitors++;
      else if (v.status === 'completed' || v.status === 'rejected') completedVisitors++;
    });

    // 3. Facility Bookings
    const { data: bookingsData, error: bookingsError } = await supabase
      .from('bookings')
      .select('status')
      .eq('society_id', SOCIETY_ID)
      .gte('created_at', startOfMonthISO);
      
    if (bookingsError) throw bookingsError;
    
    let confirmedBookings = 0;
    let pendingBookings = 0;
    
    bookingsData?.forEach(b => {
      if (b.status === 'confirmed') confirmedBookings++;
      else if (b.status === 'pending') pendingBookings++;
    });

    return {
      complaints: { open: openComplaints, resolved: resolvedComplaints, total: openComplaints + resolvedComplaints },
      visitors: { active: activeVisitors, completed: completedVisitors, total: activeVisitors + completedVisitors },
      bookings: { confirmed: confirmedBookings, pending: pendingBookings, total: confirmedBookings + pendingBookings }
    };
    
  } catch (error) {
    console.error('Error fetching reports data:', error);
    return null;
  }
}
