import styles from './facilities.module.css';
import { supabase } from '@/lib/supabase';
import { Clock, Users, IndianRupee, MapPin } from 'lucide-react';
import { approveBooking, denyBooking } from './actions';

import EditFacilityModal from './EditFacilityModal';
import CreateFacilityModal from './CreateFacilityModal';

export const revalidate = 0;

export default async function FacilitiesPage() {
  const SOCIETY_ID = process.env.NEXT_PUBLIC_SOCIETY_ID || '11111111-1111-1111-1111-111111111111';

  // Fetch facilities
  const { data: facilities } = await supabase
    .from('facilities')
    .select('*')
    .eq('society_id', SOCIETY_ID)
    .order('name');

  // Fetch bookings with facility details
  const { data: rawBookings } = await supabase
    .from('bookings')
    .select('*, facilities(name)')
    .eq('society_id', SOCIETY_ID)
    .order('created_at', { ascending: false });

  // Fetch resident details to map names and flat numbers
  const { data: details } = await supabase
    .from('v_resident_details')
    .select('resident_id, full_name, unit_number')
    .eq('society_id', SOCIETY_ID);

  const detailsMap: Record<string, any> = {};
  if (details) {
    details.forEach(d => {
      detailsMap[d.resident_id] = d;
    });
  }

  // Map bookings to include resident details
  const bookings = rawBookings?.map(b => ({
    ...b,
    resident_name: detailsMap[b.resident_id]?.full_name || 'Unknown Resident',
    unit_number: detailsMap[b.resident_id]?.unit_number || 'Unknown Flat',
    facility_name: (b.facilities as any)?.name || 'Unknown Facility'
  })) || [];

  return (
    <div className={styles.container}>
      <div className={styles.header}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
          <div>
            <h1 className={styles.title}>Facility Management</h1>
            <p className={styles.subtitle}>Manage amenities and approve resident booking requests</p>
          </div>
          <CreateFacilityModal societyId={SOCIETY_ID} />
        </div>
      </div>

      <h2 className={styles.sectionTitle}>Available Amenities</h2>
      <div className={styles.facilitiesGrid}>
        {facilities?.length === 0 ? (
          <div className={styles.emptyState} style={{ gridColumn: '1 / -1' }}>
            No facilities created yet. Click "Add New Facility" to get started!
          </div>
        ) : (
          facilities?.map((facility) => (
          <div key={facility.id} className={styles.facilityCard}>
            <div className={styles.facilityHeader}>
              <div className={styles.facilityName}>{facility.name}</div>
              <div className={`${styles.facilityStatus} ${styles['status' + facility.status]}`}>
                {facility.status}
              </div>
            </div>
            
            <div className={styles.facilityMeta}>
              <div className={styles.metaItem}>
                <Clock size={14} /> {facility.operating_hours} (Slots: {facility.slot_duration}h)
              </div>
              <div className={styles.metaItem}>
                <Users size={14} /> Capacity: {facility.capacity} pax
              </div>
              <EditFacilityModal facility={facility} />
            </div>
            
            <div className={styles.facilityPrice}>
              <IndianRupee size={16} /> 
              {facility.booking_fee}
              <span className={styles.priceLabel}> / booking</span>
            </div>
          </div>
        ))
      )}
      </div>

      <h2 className={styles.sectionTitle}>Recent Booking Requests</h2>
      <div className={styles.bookingsList}>
        {bookings.length === 0 ? (
          <div className={styles.emptyState}>No booking requests found.</div>
        ) : (
          bookings.map((booking) => (
            <div key={booking.id} className={styles.bookingItem}>
              <div className={styles.bookingInfo}>
                <div className={styles.bookingAvatar}>
                  {booking.resident_name.charAt(0).toUpperCase()}
                </div>
                <div className={styles.bookingDetails}>
                  <div className={styles.residentName}>{booking.resident_name}</div>
                  <div className={styles.bookingMeta}>
                    <div className={styles.bookingMetaItem}>
                      <MapPin size={12} /> Flat: {booking.unit_number}
                    </div>
                    <div className={styles.bookingMetaItem}>
                      • {booking.facility_name}
                    </div>
                  </div>
                  <div className={styles.bookingTime}>
                    {new Date(booking.booking_date).toLocaleDateString()} ({booking.start_time.substring(0,5)} - {booking.end_time.substring(0,5)})
                  </div>
                </div>
              </div>
              
              <div className={styles.bookingActions}>
                <div className={`${styles.bookingStatusBadge} ${styles['status' + booking.status]}`}>
                  {booking.status}
                </div>
                
                {booking.status === 'pending' && (
                  <div className={styles.actionButtons}>
                    <form action={approveBooking}>
                      <input type="hidden" name="id" value={booking.id} />
                      <input type="hidden" name="society_id" value={SOCIETY_ID} />
                      <button type="submit" className={styles.btnApprove}>Approve</button>
                    </form>
                    <form action={denyBooking}>
                      <input type="hidden" name="id" value={booking.id} />
                      <input type="hidden" name="society_id" value={SOCIETY_ID} />
                      <button type="submit" className={styles.btnDeny}>Deny</button>
                    </form>
                  </div>
                )}
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
