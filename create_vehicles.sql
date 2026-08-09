-- Create ENUM if it doesn't exist (assuming public.vehicle_type exists from schema)
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'vehicle_type') THEN
        CREATE TYPE public.vehicle_type AS ENUM ('car', 'bike', 'other');
    END IF;
END $$;

ALTER TYPE public.vehicle_type ADD VALUE IF NOT EXISTS 'bike';
ALTER TYPE public.vehicle_type ADD VALUE IF NOT EXISTS 'other';

-- Drop table if exists to replace it with the new schema provided by user
DROP TABLE IF EXISTS public.vehicles CASCADE;

create table public.vehicles (
  id uuid not null default extensions.uuid_generate_v4 (),
  resident_id uuid not null,
  vehicle_type public.vehicle_type not null default 'car'::vehicle_type,
  make text null,
  model text null,
  color text null,
  registration_no text not null,
  is_active boolean not null default true,
  created_at timestamp with time zone not null default now(),
  constraint vehicles_pkey primary key (id),
  constraint vehicles_resident_id_registration_no_key unique (resident_id, registration_no),
  constraint vehicles_resident_id_fkey foreign KEY (resident_id) references residents (id) on delete CASCADE
) TABLESPACE pg_default;

-- Enable RLS
ALTER TABLE public.vehicles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable all access for all users" ON public.vehicles FOR ALL USING (true) WITH CHECK (true);

-- Insert dummy data for default test user
INSERT INTO public.vehicles (resident_id, vehicle_type, make, model, color, registration_no) VALUES
('55555555-5555-5555-5555-555555555555', 'car', 'Toyota', 'Camry', 'Silver', 'KA-01-AB-1234')
ON CONFLICT DO NOTHING;
