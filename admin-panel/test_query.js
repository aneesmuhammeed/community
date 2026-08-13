const { createClient } = require('@supabase/supabase-js');
require('dotenv').config({ path: './.env.local' });

const supabase = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);
const SOCIETY_ID = process.env.NEXT_PUBLIC_SOCIETY_ID;

async function run() {
  const { data: apts, error: aptsErr } = await supabase
    .from('apartments')
    .select('id, unit_number, floor, blocks(name)')
    .eq('society_id', SOCIETY_ID)
    .limit(1);

  console.log("Apts Error:", aptsErr);
  console.log("Apts Data:", JSON.stringify(apts, null, 2));
}

run();
