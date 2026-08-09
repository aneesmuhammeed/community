-- Add a unique constraint to prevent double bookings for the same facility, date, and time slot
-- This applies to bookings that are active (pending or confirmed).
CREATE UNIQUE INDEX IF NOT EXISTS unique_active_booking 
ON public.bookings (facility_id, booking_date, start_time) 
WHERE status != 'cancelled';
