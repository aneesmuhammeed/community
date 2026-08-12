CREATE TABLE IF NOT EXISTS public.holidays (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  society_id uuid NOT NULL,
  date date NOT NULL,
  name text NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- RLS Policies
ALTER TABLE public.holidays ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read access for all users" ON public.holidays
  FOR SELECT USING (true);

CREATE POLICY "Enable insert for all users" ON public.holidays
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable delete for all users" ON public.holidays
  FOR DELETE USING (true);
