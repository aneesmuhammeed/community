-- Create family_members table
DROP TABLE IF EXISTS public.family_members CASCADE;

CREATE TABLE IF NOT EXISTS public.family_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    resident_id UUID NOT NULL REFERENCES public.residents(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    relation VARCHAR(50) NOT NULL CHECK (relation IN ('Spouse', 'Child', 'Parent', 'Sibling', 'Other')),
    gender VARCHAR(20) NOT NULL CHECK (gender IN ('Male', 'Female', 'Other')),
    age_group VARCHAR(20) NOT NULL CHECK (age_group IN ('Adult', 'Child', 'Senior')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.family_members ENABLE ROW LEVEL SECURITY;

-- Allow read for everyone (or you can restrict it to the authenticated user's resident_id)
CREATE POLICY "Enable read access for all users" ON public.family_members FOR SELECT USING (true);
CREATE POLICY "Enable insert access for all users" ON public.family_members FOR INSERT WITH CHECK (true);
CREATE POLICY "Enable update access for all users" ON public.family_members FOR UPDATE USING (true);
CREATE POLICY "Enable delete access for all users" ON public.family_members FOR DELETE USING (true);

-- Insert dummy data for the default test user
-- resident_id: '55555555-5555-5555-5555-555555555555'
INSERT INTO public.family_members (resident_id, name, relation, gender, age_group) VALUES
('55555555-5555-5555-5555-555555555555', 'Priya Mehta', 'Spouse', 'Female', 'Adult'),
('55555555-5555-5555-5555-555555555555', 'Rahul Mehta', 'Child', 'Male', 'Child'),
('55555555-5555-5555-5555-555555555555', 'Sushma Mehta', 'Parent', 'Female', 'Senior')
ON CONFLICT DO NOTHING;
