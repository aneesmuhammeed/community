-- Advanced Security: Prevent Database-level Overlapping Bookings
-- This requires the 'btree_gist' extension which enables advanced GiST indexing on standard data types.

-- 1. Enable the extension
CREATE EXTENSION IF NOT EXISTS btree_gist;

-- 2. Drop the simpler start_time unique index we created earlier (if it exists) to replace it with the advanced one
DROP INDEX IF EXISTS unique_active_booking;

-- 3. Add the EXCLUDE constraint
-- This ensures that for the same facility on the same date, NO two bookings can have overlapping timeranges.
-- The && operator means "overlaps".
-- We only apply this to bookings that are NOT cancelled.
ALTER TABLE public.bookings ADD CONSTRAINT no_overlapping_bookings
EXCLUDE USING GIST (
  facility_id WITH =,
  booking_date WITH =,
  timerange(start_time, end_time) WITH &&
) WHERE (status != 'cancelled');
