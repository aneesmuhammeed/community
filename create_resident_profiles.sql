DROP TABLE IF EXISTS public.resident_profiles CASCADE;

create table public.resident_profiles (
  id uuid not null default extensions.uuid_generate_v4 (),
  name text not null,
  society_name text not null,
  block text not null,
  apartment text not null,
  phone text not null,
  email text not null,
  role text not null,
  resident_type text not null,
  gender text not null,
  age_group text not null,
  heritage text not null,
  avatar_index integer not null default 0,
  created_at timestamp with time zone not null default timezone ('utc'::text, now()),
  constraint resident_profiles_pkey primary key (id)
) TABLESPACE pg_default;

-- Enable RLS
ALTER TABLE public.resident_profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable all access for all users" ON public.resident_profiles FOR ALL USING (true) WITH CHECK (true);

-- Insert the dummy test user to map exactly to the UserModel default testUser
INSERT INTO public.resident_profiles (
  id, name, society_name, block, apartment, phone, email, role, resident_type, gender, age_group, heritage, avatar_index
) VALUES (
  '55555555-5555-5555-5555-555555555555',
  'Arjun Mehta',
  'Maple Heights Residency',
  'Block A',
  'A-405',
  '+91 98765 43210',
  'arjun.mehta@gmail.com',
  'Resident',
  'Owner',
  'male',
  '25-35',
  'South Asian',
  0
) ON CONFLICT DO NOTHING;
