import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://cqotnvittlldtyekpgam.supabase.co';
const supabaseKey = 'sb_publishable_8c1pSPTJIbo_bYlGlHmpOA_7LoARw1C';
const supabase = createClient(supabaseUrl, supabaseKey);

async function createTestUser() {
  const email = 'anees@gmail.com';
  const password = 'anees@2004';

  console.log(`Attempting to sign up ${email}...`);
  
  const { data, error } = await supabase.auth.signUp({
    email: email,
    password: password,
  });

  if (error) {
    console.error('Error creating user:', error.message);
  } else {
    console.log('User created successfully!');
    console.log('Email:', email);
    console.log('Password:', password);
  }
}

createTestUser();
