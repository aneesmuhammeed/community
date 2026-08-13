const { createClient } = require('@supabase/supabase-js');

// These credentials must be the SERVICE_ROLE_KEY to bypass RLS and create users directly
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://cqotnvittlldtyekpgam.supabase.co';
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY; // The user will need to provide this

if (!supabaseServiceKey) {
  console.error("ERROR: Please set the SUPABASE_SERVICE_ROLE_KEY environment variable to run this script.");
  console.error("You can find this in your Supabase Dashboard -> Project Settings -> API.");
  process.exit(1);
}

const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

async function createTestUsers() {
  console.log("Creating test users for RBAC...");

  // 1. Super Admin
  const adminRes = await supabaseAdmin.auth.admin.createUser({
    email: 'admin@society.com',
    password: 'password123',
    email_confirm: true
  });
  if (adminRes.error) {
    console.log("Admin creation error (might already exist):", adminRes.error.message);
  } else {
    console.log("✅ Super Admin created: admin@society.com / password123");
  }

  // 2. Security Guard
  const guardRes = await supabaseAdmin.auth.admin.createUser({
    email: 'guard@society.com',
    password: 'password123',
    email_confirm: true
  });
  if (guardRes.error) {
    console.log("Guard creation error (might already exist):", guardRes.error.message);
  } else {
    console.log("✅ Security Guard created: guard@society.com / password123");
  }

  console.log("\nDone!");
}

createTestUsers();
