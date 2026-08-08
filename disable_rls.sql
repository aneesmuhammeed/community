-- Disable Row Level Security on the relevant tables so that the app can read/write without authentication for now
ALTER TABLE public.visitors DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements DISABLE ROW LEVEL SECURITY;

-- If you prefer to keep RLS enabled but allow public anonymous access, you can run these instead:
-- CREATE POLICY "Allow public read access on visitors" ON public.visitors FOR SELECT USING (true);
-- CREATE POLICY "Allow public read access on announcements" ON public.announcements FOR SELECT USING (true);
