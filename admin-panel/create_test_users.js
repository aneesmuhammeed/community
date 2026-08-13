const { createClient } = require('@supabase/supabase-js');

// These credentials must be the SERVICE_ROLE_KEY to bypass RLS and create users directly
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || 'https://cqotnvittlldtyekpgam.supabase.co';
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY; 

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
    email_confirm: true,
    user_metadata: { name: 'Super Admin' },
    app_metadata: { role: 'SUPER_ADMIN' }
  });
  if (adminRes.error) {
    if (adminRes.error.message.includes('already been registered')) {
        // Update the existing user with the new role
        const { data: users } = await supabaseAdmin.auth.admin.listUsers();
        const user = users.users.find(u => u.email === 'admin@society.com');
        if (user) {
            await supabaseAdmin.auth.admin.updateUserById(user.id, { app_metadata: { role: 'SUPER_ADMIN' } });
            console.log("✅ Super Admin updated with new JWT role: admin@society.com / password123");
        }
    } else {
        console.log("Admin creation error:", adminRes.error.message);
    }
  } else {
    console.log("✅ Super Admin created: admin@society.com / password123");
  }

  // 2. Security Guard
  const guardRes = await supabaseAdmin.auth.admin.createUser({
    email: 'guard@society.com',
    password: 'password123',
    email_confirm: true,
    user_metadata: { name: 'Security Guard' },
    app_metadata: { role: 'SECURITY_GUARD' }
  });
  if (guardRes.error) {
    if (guardRes.error.message.includes('already been registered')) {
        const { data: users } = await supabaseAdmin.auth.admin.listUsers();
        const user = users.users.find(u => u.email === 'guard@society.com');
        if (user) {
            await supabaseAdmin.auth.admin.updateUserById(user.id, { app_metadata: { role: 'SECURITY_GUARD' } });
            console.log("✅ Security Guard updated with new JWT role: guard@society.com / password123");
        }
    } else {
        console.log("Guard creation error:", guardRes.error.message);
    }
  } else {
    console.log("✅ Security Guard created: guard@society.com / password123");
  }

  // 3. Community Head
  const headRes = await supabaseAdmin.auth.admin.createUser({
    email: 'head@society.com',
    password: 'password123',
    email_confirm: true,
    user_metadata: { name: 'Community Head' },
    app_metadata: { role: 'COMMUNITY_HEAD' }
  });
  if (headRes.error) {
    if (headRes.error.message.includes('already been registered')) {
        const { data: users } = await supabaseAdmin.auth.admin.listUsers();
        const user = users.users.find(u => u.email === 'head@society.com');
        if (user) {
            await supabaseAdmin.auth.admin.updateUserById(user.id, { app_metadata: { role: 'COMMUNITY_HEAD' } });
            console.log("✅ Community Head updated with new JWT role: head@society.com / password123");
        }
    } else {
        console.log("Head creation error:", headRes.error.message);
    }
  } else {
    console.log("✅ Community Head created: head@society.com / password123");
  }

  // 4. Facility Manager
  const managerRes = await supabaseAdmin.auth.admin.createUser({
    email: 'manager@society.com',
    password: 'password123',
    email_confirm: true,
    user_metadata: { name: 'Facility Manager' },
    app_metadata: { role: 'FACILITY_MANAGER' }
  });
  if (managerRes.error) {
    if (managerRes.error.message.includes('already been registered')) {
        const { data: users } = await supabaseAdmin.auth.admin.listUsers();
        const user = users.users.find(u => u.email === 'manager@society.com');
        if (user) {
            await supabaseAdmin.auth.admin.updateUserById(user.id, { app_metadata: { role: 'FACILITY_MANAGER' } });
            console.log("✅ Facility Manager updated with new JWT role: manager@society.com / password123");
        }
    } else {
        console.log("Manager creation error:", managerRes.error.message);
    }
  } else {
    console.log("✅ Facility Manager created: manager@society.com / password123");
  }

  // 5. Accountant
  const accountantRes = await supabaseAdmin.auth.admin.createUser({
    email: 'accountant@society.com',
    password: 'password123',
    email_confirm: true,
    user_metadata: { name: 'Accountant' },
    app_metadata: { role: 'ACCOUNTANT' }
  });
  if (accountantRes.error) {
    if (accountantRes.error.message.includes('already been registered')) {
        const { data: users } = await supabaseAdmin.auth.admin.listUsers();
        const user = users.users.find(u => u.email === 'accountant@society.com');
        if (user) {
            await supabaseAdmin.auth.admin.updateUserById(user.id, { app_metadata: { role: 'ACCOUNTANT' } });
            console.log("✅ Accountant updated with new JWT role: accountant@society.com / password123");
        }
    } else {
        console.log("Accountant creation error:", accountantRes.error.message);
    }
  } else {
    console.log("✅ Accountant created: accountant@society.com / password123");
  }

  console.log("\nDone!");
}

createTestUsers();
