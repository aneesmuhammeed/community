import { createClient } from './server';
import { cookies } from 'next/headers';

export async function requireRole(allowedRoles: string[]) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    throw new Error('Unauthorized: User not authenticated');
  }

  const role = user.app_metadata?.role || 'SUPER_ADMIN';

  if (!allowedRoles.includes(role)) {
    throw new Error(`Unauthorized: Role '${role}' lacks permission`);
  }

  return { user, role };
}

export async function getSocietyId() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  
  const role = user?.app_metadata?.role || 'SUPER_ADMIN';
  
  if (role === 'SUPER_ADMIN') {
    const cookieStore = await cookies();
    const selected = cookieStore.get('selected_society_id')?.value;
    if (selected) return selected;
    return process.env.NEXT_PUBLIC_SOCIETY_ID || '11111111-1111-1111-1111-111111111111';
  }
  
  return user?.app_metadata?.society_id || process.env.NEXT_PUBLIC_SOCIETY_ID || '11111111-1111-1111-1111-111111111111';
}
