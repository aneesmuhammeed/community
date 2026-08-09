-- Script to create an admin user directly in Supabase
-- Run this in the Supabase SQL Editor if the API signup fails

DO $$ 
DECLARE
  new_user_id UUID := gen_random_uuid();
BEGIN

  -- 1. Insert into auth.users
  INSERT INTO auth.users (
    id,
    instance_id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    recovery_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
  )
  VALUES (
    new_user_id,
    '00000000-0000-0000-0000-000000000000',
    'authenticated',
    'authenticated',
    'anees@gmail.com',
    crypt('anees@2004', gen_salt('bf')),
    now(),
    now(),
    now(),
    '{"provider":"email","providers":["email"]}',
    '{}',
    now(),
    now(),
    '',
    '',
    '',
    ''
  );

  -- 2. Insert into public.profiles (if you have one)
  INSERT INTO public.profiles (id, full_name) 
  VALUES (new_user_id, 'Admin Anees')
  ON CONFLICT DO NOTHING;

  -- 3. You can also insert into a specific admin table if one exists
  -- INSERT INTO public.admins (id, user_id) VALUES (gen_random_uuid(), new_user_id);

END $$;
