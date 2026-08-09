-- This script sets up an automated background job in your Supabase database
-- to automatically delete any visitors with a 'cancelled' status after 1 hour.

-- 1. Ensure the visitors table has an updated_at column
ALTER TABLE public.visitors ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- 2. Enable the moddatetime extension (built-in to Supabase) to auto-update the timestamp
CREATE EXTENSION IF NOT EXISTS moddatetime SCHEMA extensions;

-- 3. Add a trigger to update 'updated_at' automatically on every row update
DROP TRIGGER IF EXISTS handle_updated_at_visitors ON public.visitors;
CREATE TRIGGER handle_updated_at_visitors
  BEFORE UPDATE ON public.visitors
  FOR EACH ROW
  EXECUTE PROCEDURE moddatetime(updated_at);

-- 4. Create the cleanup function
CREATE OR REPLACE FUNCTION delete_old_cancelled_visitors()
RETURNS void AS $$
BEGIN
  DELETE FROM public.visitors
  WHERE status = 'cancelled'
    AND updated_at < NOW() - INTERVAL '1 hour';
END;
$$ LANGUAGE plpgsql;

-- 5. Enable the pg_cron extension for scheduling (must be done by a superuser / via Supabase Dashboard)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- 6. Schedule the cleanup function to run every hour at minute 0
SELECT cron.schedule(
  'cleanup-cancelled-visitors', 
  '0 * * * *', 
  'SELECT delete_old_cancelled_visitors()'
);
