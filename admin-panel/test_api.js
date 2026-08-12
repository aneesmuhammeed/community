const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://cqotnvittlldtyekpgam.supabase.co';
const supabaseKey = 'sb_publishable_8c1pSPTJIbo_bYlGlHmpOA_7LoARw1C';
const supabase = createClient(supabaseUrl, supabaseKey);

async function run() {
  const { data: s } = await supabase.from('societies').select('id').limit(1);
  const SOCIETY_ID = s[0]?.id;
  
  const { data: apts } = await supabase.from('apartments').select('id').limit(1);
  const APARTMENT_ID = apts[0]?.id;

  if (!SOCIETY_ID || !APARTMENT_ID) {
    console.log("No society or apartment");
    return;
  }

  console.log("Attempting insert...");
  const { data, error } = await supabase.from('billing_cycles').insert({
    society_id: SOCIETY_ID,
    apartment_id: APARTMENT_ID,
    billing_month: 'January',
    billing_year: 2026,
    base_amount: 100,
    electricity: 0,
    water: 0,
    housekeeping: 0,
    security: 0,
    repairs: 0,
    miscellaneous: 0,
    total_amount: 100,
    due_date: '2026-08-30',
    status: 'pending',
  }).select('*');

  console.log("Insert result:", data);
  console.log("Insert error:", error);
}
run();
