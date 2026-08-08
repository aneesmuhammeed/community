import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://cqotnvittlldtyekpgam.supabase.co';
const supabaseKey = 'sb_publishable_8c1pSPTJIbo_bYlGlHmpOA_7LoARw1C';
const supabase = createClient(supabaseUrl, supabaseKey);

async function check() {
  const { data, error } = await supabase.from('announcements').select('*').limit(1);
  if (error) {
    console.error('Error:', error);
  } else {
    console.log('Success, table exists! Data:', data);
  }
}

check();
