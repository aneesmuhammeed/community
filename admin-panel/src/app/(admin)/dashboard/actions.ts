'use server'

import { supabase } from '@/lib/supabase';
import { revalidatePath } from 'next/cache';

const SOCIETY_ID = process.env.NEXT_PUBLIC_SOCIETY_ID;

export async function approveVisitor(formData: FormData) {
  const id = formData.get('id') as string;
  if (!id) return { error: 'Missing ID' };
  const { error } = await supabase.from('visitors').update({ 
    status: 'approved',
    arrived_at: new Date().toISOString()
  }).eq('id', id);
  
  if (error) return { error: error.message };
  
  revalidatePath('/dashboard');
  revalidatePath('/visitors');
  return { success: true };
}

export async function denyVisitor(formData: FormData) {
  const id = formData.get('id') as string;
  if (!id) return { error: 'Missing ID' };
  const { error } = await supabase.from('visitors').update({ status: 'cancelled' }).eq('id', id);
  if (error) return { error: error.message };
  
  revalidatePath('/dashboard');
  revalidatePath('/visitors');
  return { success: true };
}

export async function verifyOtp(formData: FormData) {
  if (!SOCIETY_ID) return { error: 'Society ID not configured' };
  const otp = formData.get('otp') as string;
  const flat = formData.get('flat') as string;
  if (!otp || !flat) return { error: 'Flat Number and OTP are required' };
  
  // 1. Resolve flat number to apartment_id via view (bypasses RLS on apartments table)
  const { data: aptData, error: aptError } = await supabase
    .from('v_resident_details')
    .select('apartment_id')
    .eq('society_id', SOCIETY_ID)
    .ilike('unit_number', flat.trim()) // case-insensitive match (e.g., a-405 matches A-405)
    .limit(1);

  if (aptError || !aptData || aptData.length === 0) {
    return { error: 'Invalid Flat Number' };
  }

  const apartmentId = aptData[0].apartment_id;

  // Find active visitor with this apartment_id and OTP
  const { data: visitors, error } = await supabase
    .from('visitors')
    .select('id, valid_until')
    .eq('society_id', SOCIETY_ID)
    .eq('apartment_id', apartmentId)
    .eq('otp_value', otp.trim())
    .in('status', ['active', 'pending'])
    .limit(1);

  if (error || !visitors || visitors.length === 0) {
    return { error: 'Invalid OTP or this pass has already been used.' };
  }

  // Check if pass has expired based on valid_until
  const validUntil = new Date(visitors[0].valid_until).getTime();
  const nowTime = new Date().getTime();

  if (nowTime > validUntil) {
    await supabase.from('visitors').update({ status: 'expired' }).eq('id', visitors[0].id);
    return { error: 'This pass has expired.' };
  }

  // Use 'approved' instead of 'entered' to avoid ENUM constraint errors, but stamp arrived_at
  const { error: updateError } = await supabase
    .from('visitors')
    .update({ 
      status: 'approved', 
      arrived_at: new Date().toISOString()
    })
    .eq('id', visitors[0].id);

  if (updateError) {
    return { error: `Database Error: ${updateError.message}` };
  }

  revalidatePath('/dashboard');
  revalidatePath('/visitors');
  
  return { success: true };
}

export async function checkoutVisitor(formData: FormData) {
  const id = formData.get('id') as string;
  if (!id) return;
  
  await supabase
    .from('visitors')
    .update({ 
      status: 'expired', // or 'left' if you have it, but we can just use expired/used. Let's use 'expired' for now as per schema logic.
      left_at: new Date().toISOString()
    })
    .eq('id', id);
    
  revalidatePath('/dashboard');
  revalidatePath('/visitors');
}
