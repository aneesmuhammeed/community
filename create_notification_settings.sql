-- Create user_notification_settings table
DROP TABLE IF EXISTS public.user_notification_settings CASCADE;

CREATE TABLE IF NOT EXISTS public.user_notification_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    resident_id UUID NOT NULL REFERENCES public.residents(id) ON DELETE CASCADE UNIQUE,
    global_push_enabled BOOLEAN NOT NULL DEFAULT true,
    announcements_enabled BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.user_notification_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Enable read access for all users" ON public.user_notification_settings FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all users" ON public.user_notification_settings FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update access for all users" ON public.user_notification_settings FOR UPDATE USING (true);
CREATE POLICY "Enable delete access for all users" ON public.user_notification_settings FOR DELETE USING (true);

-- Trigger to update 'updated_at' column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = NOW();
   RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_user_notification_settings_updated_at ON public.user_notification_settings;
CREATE TRIGGER update_user_notification_settings_updated_at
BEFORE UPDATE ON public.user_notification_settings
FOR EACH ROW
EXECUTE PROCEDURE update_updated_at_column();

-- Insert dummy data for default test user
INSERT INTO public.user_notification_settings (resident_id, global_push_enabled, announcements_enabled) VALUES
('55555555-5555-5555-5555-555555555555', true, true)
ON CONFLICT (resident_id) DO NOTHING;
