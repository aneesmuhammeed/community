import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://cqotnvittlldtyekpgam.supabase.co';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'sb_publishable_8c1pSPTJIbo_bYlGlHmpOA_7LoARw1C';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
