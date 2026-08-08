const { createClient } = require('@supabase/supabase-js');
const supabaseUrl = 'https://cqotnvittlldtyekpgam.supabase.co';
const supabaseKey = 'sb_publishable_8c1pSPTJIbo_bYlGlHmpOA_7LoARw1C';
const supabase = createClient(supabaseUrl, supabaseKey);

async function run() {
  console.log("Fetching visitors...");
  const { data, error } = await supabase
    .from('visitors')
    .select('id, otp_value, status, apartments!inner(unit_number)')
    .order('created_at', { ascending: false })
    .limit(3);
    
  console.log("Error:", error);
  console.log("Data:", JSON.stringify(data, null, 2));
}
run();
