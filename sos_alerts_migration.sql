-- Create the SOS Alerts table
CREATE TABLE IF NOT EXISTS public.sos_alerts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    resident_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'resolved')),
    resolved_at TIMESTAMP WITH TIME ZONE,
    resolved_by UUID REFERENCES auth.users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.sos_alerts ENABLE ROW LEVEL SECURITY;

-- Allow public CRUD (just like other tables in setup_public_rls.sql, assuming development mode)
-- WARNING: THESE POLICIES ALLOW ANYONE TO DO FULL CRUD WITHOUT LOGGING IN.
-- THIS IS FOR DEVELOPMENT/TESTING ONLY. DO NOT USE IN PRODUCTION.
DROP POLICY IF EXISTS "Public CRUD for sos_alerts" ON public.sos_alerts;
CREATE POLICY "Public CRUD for sos_alerts"
ON public.sos_alerts FOR ALL
TO public
USING (true)
WITH CHECK (true);

-- Enable Realtime for the sos_alerts table
-- NOTE: If supabase_realtime publication already exists, this might fail, so we just add the table.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'sos_alerts'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.sos_alerts;
  END IF;
EXCEPTION
  WHEN undefined_object THEN
    -- If publication doesn't exist, create it
    CREATE PUBLICATION supabase_realtime;
    ALTER PUBLICATION supabase_realtime ADD TABLE public.sos_alerts;
END $$;
