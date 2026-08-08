'use server'

import { supabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';

const SOCIETY_ID = '11111111-1111-1111-1111-111111111111';

export async function verifyScannedCode(code: string) {
  if (!code) return { error: 'No code provided.' };

  // Note: Since visitors has nested relations requiring RLS, we fetch the basic details
  // and use v_resident_details to get the resident names, just like in dashboard.
  const { data: visitors, error } = await supabase
    .from('visitors')
    .select('*')
    .eq('society_id', SOCIETY_ID)
    .eq('invite_code', code)
    .limit(1);

  if (error || !visitors || visitors.length === 0) {
    return { error: 'Invalid QR Code or invite not found.' };
  }

  const visitor = visitors[0];

  // Fetch resident and apartment info
  const { data: details } = await supabase
    .from('v_resident_details')
    .select('full_name, unit_number')
    .eq('resident_id', visitor.resident_id)
    .limit(1);

  const residentName = details?.[0]?.full_name || 'Unknown Resident';
  const unitNumber = details?.[0]?.unit_number || 'Unknown Flat';

  if (visitor.status === 'cancelled') {
    return { error: 'This pass has been cancelled by the resident.' };
  }
  if (visitor.status === 'expired' || visitor.status === 'entered') {
    return { error: `This pass has already been ${visitor.status}.` };
  }
  
  // Check validity windows
  const now = new Date().getTime();
  const validFrom = new Date(visitor.valid_from).getTime();
  const validUntil = new Date(visitor.valid_until).getTime();

  if (now < validFrom) {
    return { error: 'This pass is not valid yet.' };
  }
  if (now > validUntil) {
    return { error: 'This pass has expired.' };
  }

  return {
    success: true,
    visitor: {
      id: visitor.id,
      guest_name: visitor.guest_name,
      purpose: visitor.purpose,
      resident_name: residentName,
      unit_number: unitNumber,
    }
  };
}

export async function approveScannedEntry(id: string) {
  if (!id) return { error: 'Invalid ID' };

  const { error } = await supabase
    .from('visitors')
    .update({ 
      status: 'approved', 
      arrived_at: new Date().toISOString() 
    })
    .eq('id', id);

  if (error) {
    return { error: error.message };
  }

  revalidatePath('/dashboard');
  revalidatePath('/visitors');
  
  return { success: true };
}
