import fs from 'fs';

// Read env variables
const env = fs.readFileSync('.env.local', 'utf8').split('\n');
const envVars = {};
env.forEach(line => {
  if (line.trim() && !line.startsWith('#')) {
    const [key, ...value] = line.split('=');
    if (key) envVars[key.trim()] = value.join('=').trim();
  }
});

const url = envVars.NEXT_PUBLIC_SUPABASE_URL + '/rest/v1/billing_cycles?select=*%2Capartments(unit_number%2Cblocks(name))&limit=1';

const res = await fetch(url, {
  headers: {
    'apikey': envVars.NEXT_PUBLIC_SUPABASE_ANON_KEY,
    'Authorization': 'Bearer ' + envVars.NEXT_PUBLIC_SUPABASE_ANON_KEY,
  }
});

const json = await res.json();
console.log(JSON.stringify(json, null, 2));

const url2 = envVars.NEXT_PUBLIC_SUPABASE_URL + '/rest/v1/apartments?select=id%2Cunit_number%2Cfloor%2Cblocks(name)&limit=1';
const res2 = await fetch(url2, {
  headers: {
    'apikey': envVars.NEXT_PUBLIC_SUPABASE_ANON_KEY,
    'Authorization': 'Bearer ' + envVars.NEXT_PUBLIC_SUPABASE_ANON_KEY,
  }
});
const json2 = await res2.json();
console.log("APARTMENTS:", JSON.stringify(json2, null, 2));

