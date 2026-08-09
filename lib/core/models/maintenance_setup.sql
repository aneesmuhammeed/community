-- ============================================================
-- Maintenance & Billing Setup
-- ============================================================

-- Disable RLS on the existing billing_cycles table
ALTER TABLE public.billing_cycles DISABLE ROW LEVEL SECURITY;

-- Seed sample data
INSERT INTO public.billing_cycles (
  id,
  society_id,
  apartment_id,
  billing_month,
  billing_year,
  total_amount,
  due_date,
  paid_at,
  paid_amount,
  status
)
VALUES
  (
    gen_random_uuid(),
    '11111111-1111-1111-1111-111111111111',
    '33333333-3333-3333-3333-333333333333',
    'December',
    2024,
    3500,
    '2024-12-05',
    NULL,
    0,
    'pending'
  ),
  (
    gen_random_uuid(),
    '11111111-1111-1111-1111-111111111111',
    '33333333-3333-3333-3333-333333333333',
    'November',
    2024,
    3500,
    '2024-11-05',
    '2024-11-03 10:30:00+00',
    3500,
    'paid'
  ),
  (
    gen_random_uuid(),
    '11111111-1111-1111-1111-111111111111',
    '33333333-3333-3333-3333-333333333333',
    'October',
    2024,
    3500,
    '2024-10-05',
    '2024-10-04 09:15:00+00',
    3500,
    'paid'
  ),
  (
    gen_random_uuid(),
    '11111111-1111-1111-1111-111111111111',
    '33333333-3333-3333-3333-333333333333',
    'September',
    2024,
    3200,
    '2024-09-05',
    '2024-09-02 11:00:00+00',
    3200,
    'paid'
  ),
  (
    gen_random_uuid(),
    '11111111-1111-1111-1111-111111111111',
    '33333333-3333-3333-333333333333',
    'August',
    2024,
    3200,
    '2024-08-05',
    '2024-08-01 14:20:00+00',
    3200,
    'paid'
  )
ON CONFLICT DO NOTHING;