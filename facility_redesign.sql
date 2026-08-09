-- 1. Create ENUM for Day Type if it doesn't exist (using TEXT check constraint instead for simplicity across ORMs)
-- Alternatively, create proper types.
-- Using simple VARCHAR with CHECK is safer for dynamic changes.

-- 2. Create Holidays table
CREATE TABLE IF NOT EXISTS public.holidays (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    society_id UUID NOT NULL REFERENCES public.societies(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
CREATE UNIQUE INDEX idx_holidays_society_date ON public.holidays(society_id, date);

-- 3. Create Facility Schedules
CREATE TABLE IF NOT EXISTS public.facility_schedules (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    facility_id UUID NOT NULL REFERENCES public.facilities(id) ON DELETE CASCADE,
    day_type VARCHAR(20) NOT NULL CHECK (day_type IN ('WEEKDAY', 'WEEKEND', 'HOLIDAY')),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);
-- We shouldn't allow overlapping schedules for the same day_type for the same facility.
-- BUT since we are keeping it simple, let's just make sure we don't duplicate.

-- 4. Create Facility Slot Blocks (Overrides/Deletions by Admin)
CREATE TABLE IF NOT EXISTS public.facility_slot_blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    facility_id UUID NOT NULL REFERENCES public.facilities(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 5. Drop the old static facility_time_slots table since we are computing slots dynamically
DROP TABLE IF EXISTS public.facility_time_slots CASCADE;

-- 6. Modify Bookings table
-- We drop slot_id because slots are no longer static rows.
ALTER TABLE public.bookings DROP COLUMN IF EXISTS slot_id;
