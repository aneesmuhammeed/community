const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: './admin-panel/.env.local' }); // Assuming env is here

const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);
const SOCIETY_ID = process.env.NEXT_PUBLIC_SOCIETY_ID;

async function run() {
  console.log("SOCIETY_ID:", SOCIETY_ID);
  
  const { data: bills, error: billsErr } = await supabase
    .from('billing_cycles')
    .select('*, apartments(unit_number, blocks(name))')
    .eq('society_id', SOCIETY_ID)
    .limit(2);
    
  console.log("Bills Error:", billsErr);
  console.log("Bills Data:", JSON.stringify(bills, null, 2));

  const { data: apts, error: aptsErr } = await supabase
    .from('apartments')
    .select('id, unit_number, floor, blocks(name)')
    .eq('society_id', SOCIETY_ID)
    .limit(2);

  console.log("Apts Error:", aptsErr);
  console.log("Apts Data:", JSON.stringify(apts, null, 2));
}

run();
