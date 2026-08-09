const { createClient } = require('@supabase/supabase-js');
const supabaseUrl = 'https://cqotnvittlldtyekpgam.supabase.co';
const supabaseKey = 'sb_publishable_8c1pSPTJIbo_bYlGlHmpOA_7LoARw1C';
const supabase = createClient(supabaseUrl, supabaseKey);

async function run() {
  console.log("Fetching schema info...");
  // Querying information_schema to get tables
  // Usually this requires a service role key, but let's see if we can query it or if we can just guess tables.
  
  const tablesToTest = ['profiles', 'users', 'residents', 'apartments', 'society', 'societies'];
  for (const table of tablesToTest) {
    const { data, error } = await supabase.from(table).select('*').limit(1);
    if (error) {
      console.log(`Table ${table} error: ${error.message}`);
    } else {
      console.log(`Table ${table} exists! Data: ${JSON.stringify(data)}`);
    }
  }
}
run();
