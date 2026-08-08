-- Seed Data for Native Schema

-- We use fixed UUIDs so they can link properly
DO $$ 
DECLARE
  society_id UUID := '11111111-1111-1111-1111-111111111111';
  block_id UUID := '22222222-2222-2222-2222-222222222222';
  apartment_id UUID := '33333333-3333-3333-3333-333333333333';
  user_id UUID := '44444444-4444-4444-4444-444444444444';
  resident_id UUID := '55555555-5555-5555-5555-555555555555';
  facility_id_1 UUID := '66666666-6666-6666-6666-666666666661';
  facility_id_2 UUID := '66666666-6666-6666-6666-666666666662';
BEGIN

-- 1. Create Core Hierarchy (Society -> Block -> Apartment -> Resident)
INSERT INTO public.societies (id, name, address, city, state) 
VALUES (society_id, 'Green Valley Heights', '123 Tech Park', 'Bangalore', 'Karnataka')
ON CONFLICT DO NOTHING;

INSERT INTO public.blocks (id, society_id, name) 
VALUES (block_id, society_id, 'Block A')
ON CONFLICT DO NOTHING;

INSERT INTO public.apartments (id, society_id, block_id, unit_number, floor, is_occupied) 
VALUES (apartment_id, society_id, block_id, 'A-405', 4, true)
ON CONFLICT DO NOTHING;

-- Temporarily disable constraint or insert dummy into auth/profiles
-- Assuming profiles table exists and requires id (which is the user_id)
-- Note: auth.users insert is complex, if it fails, the user should provide a real auth user UUID.
BEGIN
    INSERT INTO auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, recovery_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, email_change, email_change_token_new, recovery_token)
    VALUES (user_id, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'dummy@example.com', '', now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', now(), now(), '', '', '', '')
    ON CONFLICT DO NOTHING;
EXCEPTION WHEN OTHERS THEN
    -- Ignore if auth.users doesn't exist or is locked
END;

INSERT INTO public.profiles (id, full_name) 
VALUES (user_id, 'Dummy Resident')
ON CONFLICT DO NOTHING;

INSERT INTO public.residents (id, user_id, apartment_id, society_id, role, ownership, is_active) 
VALUES (resident_id, user_id, apartment_id, society_id, 'resident', 'owner', true)
ON CONFLICT DO NOTHING;

-- 2. Announcements
INSERT INTO public.announcements (society_id, title, body, tag, icon, is_pinned, is_published, publish_at) VALUES
(society_id, 'Water Supply Interruption', 'Scheduled maintenance on Nov 28, 6–10 AM.', 'maintenance', 'droplets', true, true, now()),
(society_id, 'Annual Society Meeting', 'Join us on Dec 5th at the clubhouse, 6 PM.', 'event', 'calendar', false, true, now() - INTERVAL '1 day');

-- 3. Visitors (Past / Upcoming)
INSERT INTO public.visitors (resident_id, apartment_id, society_id, guest_name, relation, purpose, invite_method, invite_code, valid_from, valid_until, valid_hours, status, arrived_at) VALUES
(resident_id, apartment_id, society_id, 'Riya Sharma', 'friend', 'Food Delivery', 'qr', 'VIS-4829', now(), now() + INTERVAL '2 hours', 2, 'active', now()),
(resident_id, apartment_id, society_id, 'James Pinto', 'family', 'Friend', 'qr', 'VIS-9104', now() - INTERVAL '1 day', now(), 2, 'expired', now() - INTERVAL '1 day');

-- 4. Facilities & Bookings
INSERT INTO public.facilities (id, society_id, name, capacity, operating_hours, booking_fee, advance_days, slot_duration, status, is_active) VALUES
(facility_id_1, society_id, 'Indoor Sports', 20, '6 AM - 10 PM', 50.0, 7, 1, 'available', true),
(facility_id_2, society_id, 'Party Hall', 100, '10 AM - 11 PM', 1500.0, 30, 4, 'available', true)
ON CONFLICT DO NOTHING;

INSERT INTO public.bookings (resident_id, facility_id, society_id, booking_date, start_time, end_time, status, booking_fee) VALUES
(resident_id, facility_id_1, society_id, CURRENT_DATE + 2, '18:00:00', '19:00:00', 'confirmed', 50.0),
(resident_id, facility_id_2, society_id, CURRENT_DATE + 15, '16:00:00', '21:00:00', 'pending', 1500.0);

-- 5. Billing Cycles (Maintenance)
INSERT INTO public.billing_cycles (apartment_id, society_id, billing_month, billing_year, base_amount, electricity, water, housekeeping, security, repairs, miscellaneous, total_amount, due_date, status, late_fee, discount) VALUES
(apartment_id, society_id, 'November', 2024, 2500, 500, 200, 100, 100, 100, 0, 3500.0, CURRENT_DATE + 10, 'pending', 0, 0),
(apartment_id, society_id, 'October', 2024, 2500, 500, 200, 100, 100, 100, 0, 3500.0, CURRENT_DATE - 20, 'paid', 0, 0),
(apartment_id, society_id, 'September', 2024, 2500, 500, 200, 100, 100, 100, 0, 3500.0, CURRENT_DATE - 50, 'paid', 0, 0);

-- 6. Complaints
INSERT INTO public.complaints (resident_id, apartment_id, society_id, title, description, category, priority, status) VALUES
(resident_id, apartment_id, society_id, 'Leaking tap in kitchen', 'Tap is leaking heavily', 'plumbing', 'high', 'in_progress'),
(resident_id, apartment_id, society_id, 'Corridor light flickering', 'Light near A-405 is flickering', 'electrical', 'low', 'resolved');

END $$;
