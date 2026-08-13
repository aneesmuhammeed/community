'use server';

import { requireRole } from '@/utils/supabase/auth';
import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';

export async function searchVehicles(searchTerm: string) {
  // Allow SECURITY_GUARD and SUPER_ADMIN
  const { user } = await requireRole(['SUPER_ADMIN', 'SECURITY_GUARD']);
  
  const cookieStore = await cookies();
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value;
        },
      },
    }
  );

  if (!searchTerm || searchTerm.trim() === '') {
    return [];
  }

  // We want to join vehicles with resident details (v_resident_details)
  // vehicles table has resident_id
  
  const { data, error } = await supabase
    .from('vehicles')
    .select(`
      id,
      make,
      model,
      color,
      registration_no,
      vehicle_type,
      is_active,
      resident_id
    `)
    .ilike('registration_no', `%${searchTerm}%`)
    .order('registration_no', { ascending: true })
    .limit(20);

  if (error) {
    console.error('Error fetching vehicles:', error);
    throw new Error('Failed to search vehicles');
  }

  if (!data || data.length === 0) return [];

  // Fetch resident details for these vehicles
  const residentIds = Array.from(new Set(data.map(v => v.resident_id)));
  
  const { data: residentsData, error: residentsError } = await supabase
    .from('v_resident_details')
    .select('user_id, name, apartment, block, phone')
    .in('user_id', residentIds);

  if (residentsError) {
    console.error('Error fetching residents:', residentsError);
    // Ignore and just return without resident info if this fails
  }

  const residentMap = new Map();
  if (residentsData) {
    residentsData.forEach(r => residentMap.set(r.user_id, r));
  }

  return data.map(vehicle => ({
    ...vehicle,
    resident: residentMap.get(vehicle.resident_id) || null
  }));
}
