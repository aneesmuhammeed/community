const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');

const env = fs.readFileSync('../.env.local', 'utf-8');
const urlMatch = env.match(/NEXT_PUBLIC_SUPABASE_URL=(.*)/);
const keyMatch = env.match(/NEXT_PUBLIC_SUPABASE_ANON_KEY=(.*)/);

const supabase = createClient(urlMatch[1], keyMatch[1]);

async function run() {
  const { data: b, error: e1 } = await supabase.from('billing_cycles').select('*').limit(1);
  console.log('billing_cycles:', b, e1);

  const { data: t, error: e2 } = await supabase.from('transactions').select('*').limit(1);
  console.log('transactions:', t, e2);
}
run();
